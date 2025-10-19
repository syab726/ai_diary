import 'dart:developer';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/image_options.dart';
import '../models/perspective_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import 'package:flutter/foundation.dart';

class AIService {
  // .env 파일에서 API 키 로드
  static String get _geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }

  // 이미지를 파일로 저장하고 파일 경로 반환
  static Future<String> _saveImageToFile(String base64Data, String mimeType) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'diary_images'));

      // 디렉토리가 없으면 생성
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 파일명 생성 (타임스탬프 기반)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = mimeType.split('/').last;
      final fileName = 'diary_image_$timestamp.$extension';
      final filePath = path.join(imagesDir.path, fileName);

      // base64 디코딩 후 파일 저장
      final imageBytes = base64Decode(base64Data);
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (kDebugMode) print('이미지 파일 저장 완료: $filePath');
      return filePath;
    } catch (e) {
      if (kDebugMode) print('이미지 파일 저장 오류: $e');
      return '';
    }
  }
  // .env 파일에서 선택적 API 키 로드
  static String get _openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get _huggingFaceApiKey => dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
  static late GenerativeModel _textModel;
  static late GenerativeModel _imageModel;

  // HTTP 요청 재시도 설정
  static const int _maxRetries = 3;
  static const Duration _requestTimeout = Duration(seconds: 30);

  // 재시도 로직이 포함된 HTTP POST 헬퍼 메서드
  static Future<http.Response> _retryablePost({
    required Uri url,
    required Map<String, String> headers,
    required String body,
  }) async {
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        if (kDebugMode && retryCount > 0) {
          print('재시도 ${retryCount + 1}/$_maxRetries...');
        }

        final response = await http.post(
          url,
          headers: headers,
          body: body,
        ).timeout(_requestTimeout);

        // 성공 또는 클라이언트 오류(4xx)면 재시도하지 않음
        if (response.statusCode < 500) {
          return response;
        }

        // 서버 오류(5xx)면 재시도
        if (kDebugMode) {
          print('서버 오류 (${response.statusCode}), 재시도 대기 중...');
        }
      } catch (e) {
        if (retryCount == _maxRetries - 1) {
          // 마지막 시도에서 실패하면 예외 발생
          rethrow;
        }
        if (kDebugMode) {
          print('HTTP 요청 오류: $e, 재시도 대기 중...');
        }
      }

      // Exponential backoff: 1초, 2초, 4초
      await Future.delayed(Duration(seconds: 1 << retryCount));
      retryCount++;
    }

    throw Exception('최대 재시도 횟수($_maxRetries)를 초과했습니다.');
  }

  static void initialize() {
    if (kDebugMode) print('=== AI Service 초기화 ===');
    if (kDebugMode) print('텍스트 모델명: gemini-2.0-flash-lite');
    if (kDebugMode) print('이미지 생성 모델명: gemini-2.5-flash-image-preview');
    if (kDebugMode) print('API 키 설정됨: ${_geminiApiKey.substring(0, 10)}...');

    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _geminiApiKey
    );
    _imageModel = GenerativeModel(
      model: 'gemini-2.5-flash-image-preview',
      apiKey: _geminiApiKey
    );

    if (kDebugMode) print('모델 초기화 완료');
  }

  static Future<String> analyzeEmotion(String diaryContent) async {
    try {
      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용의 주요 감정을 분석해주세요. 
가능한 감정: happy, sad, angry, excited, peaceful, anxious, grateful, nostalgic, romantic, frustrated
하나의 감정만 답변해주세요.

일기 내용: $diaryContent''')
      ]);
      
      return response.text?.trim() ?? 'peaceful';
    } catch (e) {
      log('감정 분석 오류: $e');
      return 'peaceful';
    }
  }

  static Future<List<String>> extractKeywords(String diaryContent) async {
    try {
      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용에서 주요 키워드 5개를 추출해주세요.
쉼표로 구분하여 답변해주세요.

일기 내용: $diaryContent''')
      ]);

      String keywords = response.text?.trim() ?? '';
      return keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
    } catch (e) {
      log('키워드 추출 오류: $e');
      return [];
    }
  }

  // 사용자 업로드 사진 분석
  static Future<String> analyzePhotos(List<String> photoPaths) async {
    if (photoPaths.isEmpty) return '';

    try {
      if (kDebugMode) print('=== 사진 분석 시작 ===');
      if (kDebugMode) print('분석할 사진 개수: ${photoPaths.length}');

      // Vision 모델 사용
      final visionModel = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: _geminiApiKey,
      );

      // 최대 3장까지만 분석
      final photosToAnalyze = photoPaths.take(3).toList();

      final List<Part> parts = [];

      // 사진 파일들을 읽어서 Parts로 변환
      for (final photoPath in photosToAnalyze) {
        try {
          final file = File(photoPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            parts.add(DataPart('image/jpeg', bytes));
            if (kDebugMode) print('사진 로드 성공: $photoPath');
          }
        } catch (e) {
          if (kDebugMode) print('사진 로드 실패: $photoPath - $e');
        }
      }

      if (parts.isEmpty) {
        print('분석 가능한 사진이 없습니다');
        return '';
      }

      // 분석 프롬프트 추가
      parts.add(TextPart('''이 사진들을 분석해서 다음 정보를 추출해주세요:
- 전체적인 분위기와 느낌
- 주요 색감과 톤
- 시간대 (아침, 낮, 저녁, 밤)
- 장소와 환경 (실내/실외, 도시/자연 등)
- 주요 피사체나 오브젝트

2-3문장으로 간결하게 요약해주세요.'''));

      final response = await visionModel.generateContent([Content.multi(parts)]);
      final analysisResult = response.text?.trim() ?? '';

      if (kDebugMode) print('사진 분석 결과: $analysisResult');
      return analysisResult;
    } catch (e) {
      if (kDebugMode) print('사진 분석 오류: $e');
      return '';
    }
  }

  static Future<String> generateImagePrompt(String diaryContent, String emotion, List<String> keywords, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageTime? imageTime, ImageWeather? imageWeather, String? photoAnalysis]) async {
    try {
      // 고급 옵션을 프롬프트 접미사로 변환
      final advancedSuffix = advancedOptions?.generatePromptSuffix() ?? '';
      // 시점 옵션을 프롬프트 접미사로 변환
      final perspectiveSuffix = perspectiveOptions?.getPromptSuffix() ?? '';
      // 시간과 날씨 정보
      final timeSuffix = imageTime != null ? '시간: ${imageTime.displayName}' : '';
      final weatherSuffix = imageWeather != null ? '날씨: ${imageWeather.displayName}' : '';
      // 사진 분석 결과
      final photoSuffix = photoAnalysis != null && photoAnalysis.isNotEmpty ? '사진 분석: $photoAnalysis' : '';

      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용을 바탕으로 이미지 생성 프롬프트를 만들어주세요.
스타일: $style
감정적이고 아름다운 이미지가 되도록 작성해주세요.

일기 내용: $diaryContent
주요 감정: $emotion
키워드: ${keywords.join(', ')}
${advancedSuffix.isNotEmpty ? '고급 옵션: $advancedSuffix' : ''}
${perspectiveSuffix.isNotEmpty ? '시점: $perspectiveSuffix' : ''}
${timeSuffix.isNotEmpty ? '시간: $timeSuffix' : ''}
${weatherSuffix.isNotEmpty ? '날씨: $weatherSuffix' : ''}
${photoSuffix.isNotEmpty ? '사용자 업로드 사진 분석:\n$photoAnalysis\n\n위 사진의 분위기, 색감, 시간대, 장소를 참고해서 일관성 있는 이미지를 생성해주세요.' : ''}

프롬프트는 영어로 작성하고, 일기의 감정과 내용을 잘 표현하는 따뜻하고 감성적인 이미지가 되도록 해주세요.
${advancedSuffix.isNotEmpty ? '고급 옵션에서 지정된 조명, 분위기, 색상, 구도 요소들을 반영해주세요.' : ''}
${perspectiveSuffix.isNotEmpty ? '시점 옵션에서 지정된 관점을 반영해주세요.' : ''}
${timeSuffix.isNotEmpty ? '지정된 시간대 ${imageTime!.displayName}의 분위기를 반영해주세요.' : ''}
${weatherSuffix.isNotEmpty ? '지정된 날씨 ${imageWeather!.displayName}의 느낌을 표현해주세요.' : ''}
${photoSuffix.isNotEmpty ? '업로드된 사진의 스타일과 분위기를 최대한 반영해주세요.' : ''}''')
      ]);

      return response.text?.trim() ?? 'A peaceful and emotional illustration';
    } catch (e) {
      log('이미지 프롬프트 생성 오류: $e');
      return 'A peaceful and emotional illustration representing daily life';
    }
  }

  static Future<String?> generateImage(String prompt, [ImageTime? imageTime, ImageWeather? imageWeather]) async {
    try {
      if (kDebugMode) print('=== Gemini Imagen API를 통한 이미지 생성 시작 ===');
      if (kDebugMode) print('프롬프트: $prompt');
      if (kDebugMode) print('적용할 시간: ${imageTime != null ? imageTime.displayName : '기본값'}');
      if (kDebugMode) print('적용할 날씨: ${imageWeather != null ? imageWeather.displayName : '기본값'}');

      try {
        if (kDebugMode) print('Gemini 2.5 Flash Image Preview 이미지 생성 시도...');

        // 시간과 날씨에 따른 프롬프트 강화
        String timePrompt = '';
        if (imageTime != null) {
          timePrompt = 'Time setting: ${imageTime.displayName}. ';
        }

        String weatherPrompt = '';
        if (imageWeather != null) {
          weatherPrompt = 'Weather: ${imageWeather.displayName}. ';
        }

        final enhancedPrompt = '$timePrompt$weatherPrompt$prompt. Ensure the image reflects the specified time and weather conditions.';

        if (kDebugMode) print('최종 강화된 프롬프트: $enhancedPrompt');

        final response = await _retryablePost(
          url: Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent?key=$_geminiApiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': enhancedPrompt
                  }
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.9,
              'topK': 1,
              'topP': 1,
              'maxOutputTokens': 8192,
            }
          }),
        );

        if (kDebugMode) print('Gemini Imagen API 응답 상태: ${response.statusCode}');
        if (kDebugMode) print('Gemini Imagen API 응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // 응답에서 이미지 데이터 찾기
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            final candidate = data['candidates'][0];
            if (candidate['content'] != null && candidate['content']['parts'] != null) {
              for (final part in candidate['content']['parts']) {
                if (part['inlineData'] != null) {
                  print('*** Gemini 2.5 Flash Image API 이미지 생성 성공! ***');
                  final imageData = part['inlineData']['data'];
                  final mimeType = part['inlineData']['mimeType'] ?? 'image/png';
                  if (kDebugMode) print('이미지 데이터 크기: ${imageData.length} characters');

                  // 이미지를 파일로 저장
                  final filePath = await _saveImageToFile(imageData, mimeType);
                  if (filePath.isNotEmpty) {
                    print('파일 저장 성공, 경로 반환: $filePath');
                    return 'file://$filePath';
                  } else {
                    if (kDebugMode) print('파일 저장 실패, base64 데이터 반환');
                    return 'data:image/png;base64,$imageData';
                  }
                }
              }
            }
          }
        } else {
          if (kDebugMode) print('Gemini Imagen API 오류: ${response.statusCode} - ${response.body}');
        }

        if (kDebugMode) print('Gemini Imagen API에서 이미지를 생성하지 못함');
      } catch (e) {
        if (kDebugMode) print('Gemini Imagen API 호출 오류: $e');
      }

      // Gemini API 실패시 폴백으로 Unsplash/Picsum 사용
      if (kDebugMode) print('폴백: Unsplash/Picsum 이미지 사용');
      final smartKeywords = _generateSmartImageKeywords(prompt);
      final fallbackImageUrl = _selectBestImageUrl(smartKeywords, prompt);
      if (kDebugMode) print('폴백 이미지 URL: $fallbackImageUrl');
      return fallbackImageUrl;

    } catch (e) {
      if (kDebugMode) print('*** 이미지 생성 실패 ***');
      if (kDebugMode) print('오류: $e');
      rethrow;
    }
  }
  
  static List<String> _generateSmartImageKeywords(String prompt) {
    final keywords = <String>[];
    final lowercasePrompt = prompt.toLowerCase();
    
    // 감정 기반 키워드
    if (lowercasePrompt.contains('peaceful') || lowercasePrompt.contains('calm') || lowercasePrompt.contains('tranquil')) {
      keywords.addAll(['peaceful', 'serene', 'calm']);
    }
    if (lowercasePrompt.contains('rain') || lowercasePrompt.contains('shower') || lowercasePrompt.contains('wet')) {
      keywords.addAll(['rain', 'rainfall', 'water']);
    }
    if (lowercasePrompt.contains('rainbow') || lowercasePrompt.contains('colorful')) {
      keywords.addAll(['rainbow', 'colors', 'sky']);
    }
    if (lowercasePrompt.contains('late afternoon') || lowercasePrompt.contains('sunset')) {
      keywords.addAll(['sunset', 'golden hour', 'afternoon']);
    }
    if (lowercasePrompt.contains('window') || lowercasePrompt.contains('indoor')) {
      keywords.addAll(['window', 'indoor', 'cozy']);
    }
    if (lowercasePrompt.contains('realistic') || lowercasePrompt.contains('photorealistic')) {
      keywords.addAll(['photography', 'realistic', 'natural']);
    }
    
    // 일반적인 장면 키워드
    if (lowercasePrompt.contains('home') || lowercasePrompt.contains('room')) {
      keywords.addAll(['home', 'interior', 'cozy']);
    }
    if (lowercasePrompt.contains('nature') || lowercasePrompt.contains('outdoor')) {
      keywords.addAll(['nature', 'landscape', 'outdoor']);
    }
    
    // 기본값이 없다면 평화로운 이미지
    if (keywords.isEmpty) {
      keywords.addAll(['peaceful', 'nature', 'beautiful']);
    }
    
    return keywords.take(4).toList();
  }
  
  static String _selectBestImageUrl(List<String> keywords, String prompt) {
    final searchTerm = keywords.join(',');

    // 기본 이미지 크기
    String dimensions = '800x800';

    if (kDebugMode) print('선택된 이미지 크기: $dimensions');

    // 다양한 이미지 소스 중에서 선택
    final sources = [
      'https://source.unsplash.com/$dimensions/?$searchTerm',
      'https://picsum.photos/${dimensions.split('x')[0]}/${dimensions.split('x')[1]}?random=${DateTime.now().millisecondsSinceEpoch}',
    ];

    // 프롬프트에 따라 더 적합한 소스 선택
    if (prompt.toLowerCase().contains('realistic') || prompt.toLowerCase().contains('photo')) {
      return sources[0]; // Unsplash (실제 사진)
    } else {
      return sources[0]; // 기본적으로 Unsplash 사용
    }
  }
  
  static List<String> _extractKeywordsFromPrompt(String prompt) {
    final keywords = <String>[];
    final lowercasePrompt = prompt.toLowerCase();
    
    // 감정 키워드
    if (lowercasePrompt.contains('peaceful') || lowercasePrompt.contains('calm')) keywords.add('peaceful');
    if (lowercasePrompt.contains('happy') || lowercasePrompt.contains('joy')) keywords.add('happy');
    if (lowercasePrompt.contains('sad') || lowercasePrompt.contains('melancholy')) keywords.add('sad');
    if (lowercasePrompt.contains('romantic') || lowercasePrompt.contains('love')) keywords.add('romantic');
    
    // 자연 키워드
    if (lowercasePrompt.contains('nature') || lowercasePrompt.contains('outdoor')) keywords.add('nature');
    if (lowercasePrompt.contains('rain') || lowercasePrompt.contains('rainbow')) keywords.add('rain');
    if (lowercasePrompt.contains('sunset') || lowercasePrompt.contains('sunrise')) keywords.add('sunset');
    if (lowercasePrompt.contains('garden') || lowercasePrompt.contains('flower')) keywords.add('garden');
    
    // 일상 키워드  
    if (lowercasePrompt.contains('daily') || lowercasePrompt.contains('life')) keywords.add('lifestyle');
    if (lowercasePrompt.contains('home') || lowercasePrompt.contains('cozy')) keywords.add('cozy');
    if (lowercasePrompt.contains('illustration') || lowercasePrompt.contains('art')) keywords.add('illustration');
    
    return keywords.isEmpty ? ['nature', 'peaceful'] : keywords.take(3).toList();
  }

  static Future<Map<String, dynamic>> autoConfigureOptions(String diaryContent) async {
    try {
      if (kDebugMode) print('=== AI 자동 설정 시작 ===');
      if (kDebugMode) print('일기 내용: $diaryContent');

      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용을 분석해서 이미지 생성에 적합한 설정들을 추천해주세요.
JSON 형태로 답변해주세요:

{
  "lighting": "natural|dramatic|warm|cool|sunset|night 중 하나",
  "mood": "peaceful|energetic|mysterious|nostalgic|dreamy|melancholic 중 하나",
  "color": "vibrant|pastel|monochrome|sepia|earthTone|neonPop 중 하나",
  "composition": "closeUp|wideAngle|birdEye|lowAngle|symmetrical|ruleOfThirds 중 하나",
  "time": "morning|afternoon|evening|night 중 하나",
  "weather": "sunny|cloudy|rainy|snowy 중 하나"
}

일기 내용: $diaryContent

일기의 분위기, 감정, 시간대, 날씨, 상황 등을 종합적으로 고려해서 가장 적합한 설정을 선택해주세요.''')
      ]);

      String responseText = response.text?.trim() ?? '';
      if (kDebugMode) print('AI 응답: $responseText');

      // JSON 파싱 시도
      try {
        // 응답에서 JSON 부분만 추출
        final jsonStart = responseText.indexOf('{');
        final jsonEnd = responseText.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = responseText.substring(jsonStart, jsonEnd + 1);
          final Map<String, dynamic> aiOptions = jsonDecode(jsonString);

          if (kDebugMode) print('파싱된 AI 옵션: $aiOptions');
          return aiOptions;
        }
      } catch (e) {
        if (kDebugMode) print('JSON 파싱 오류: $e');
      }

      // 파싱 실패시 기본값 반환
      return {
        'lighting': 'natural',
        'mood': 'peaceful',
        'color': 'vibrant',
        'composition': 'wideAngle',
        'time': 'afternoon',
        'weather': 'sunny'
      };
    } catch (e) {
      if (kDebugMode) print('AI 자동 설정 오류: $e');
      return {
        'lighting': 'natural',
        'mood': 'peaceful',
        'color': 'vibrant',
        'composition': 'wideAngle',
        'time': 'afternoon',
        'weather': 'sunny'
      };
    }
  }

  static Future<Map<String, dynamic>> processEntry(
    String diaryContent,
    String style, [
    AdvancedImageOptions? advancedOptions,
    PerspectiveOptions? perspectiveOptions,
    ImageTime? imageTime,
    ImageWeather? imageWeather,
    ImageSeason? imageSeason,
    List<String>? userPhotos,
  ]) async {
    try {
      if (kDebugMode) print('=== AI 처리 시작 ===');
      if (kDebugMode) print('일기 내용: $diaryContent');
      if (kDebugMode) print('스타일: $style');
      if (kDebugMode) print('시간 설정: ${imageTime != null ? imageTime.displayName : '기본값'}');
      if (kDebugMode) print('날씨 설정: ${imageWeather != null ? imageWeather.displayName : '기본값'}');
      if (kDebugMode) print('고급 옵션: ${advancedOptions != null ? '활성화' : '비활성화'}');
      if (kDebugMode) print('시점 옵션: ${perspectiveOptions != null ? '활성화' : '비활성화'}');
      if (kDebugMode) print('사용자 사진: ${userPhotos != null && userPhotos.isNotEmpty ? '${userPhotos.length}장' : '없음'}');

      // 사진 분석 (있으면)
      String photoAnalysis = '';
      if (userPhotos != null && userPhotos.isNotEmpty) {
        print('사용자 업로드 사진 분석 시작...');
        photoAnalysis = await analyzePhotos(userPhotos);
        if (kDebugMode) print('사진 분석 완료: $photoAnalysis');
      }

      // 병렬로 감정 분석과 키워드 추출 실행
      if (kDebugMode) print('감정 분석 및 키워드 추출 시작...');
      final futures = await Future.wait([
        analyzeEmotion(diaryContent),
        extractKeywords(diaryContent),
      ]);

      final emotion = futures[0] as String;
      final keywords = futures[1] as List<String>;

      if (kDebugMode) print('감정 분석 결과: $emotion');
      if (kDebugMode) print('키워드 추출 결과: $keywords');

      // 이미지 프롬프트 생성 (사진 분석 결과 포함)
      if (kDebugMode) print('이미지 프롬프트 생성 시작...');
      final imagePrompt = await generateImagePrompt(
        diaryContent,
        emotion,
        keywords,
        style,
        advancedOptions,
        perspectiveOptions,
        imageTime,
        imageWeather,
        photoAnalysis.isNotEmpty ? photoAnalysis : null,
      );
      if (kDebugMode) print('이미지 프롬프트 결과: $imagePrompt');

      // 이미지 생성
      if (kDebugMode) print('이미지 생성 시작...');
      final imageUrl = await generateImage(imagePrompt, imageTime, imageWeather);
      if (kDebugMode) print('이미지 생성 완료. URL: $imageUrl');

      final result = {
        'emotion': emotion,
        'keywords': keywords,
        'imagePrompt': imagePrompt,
        'imageUrl': imageUrl,
      };

      if (kDebugMode) print('=== AI 처리 완료 ===');
      if (kDebugMode) print('최종 결과: $result');

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) print('AI 처리 오류: $e');
      if (kDebugMode) print('스택 트레이스: $stackTrace');
      // 기본 폴백 이미지 크기 설정
      String fallbackDimensions = '400/400';

      return {
        'emotion': 'peaceful',
        'keywords': <String>[],
        'imagePrompt': 'A peaceful illustration',
        'imageUrl': 'https://picsum.photos/$fallbackDimensions?random=error',
      };
    }
  }

  // 감정 인사이트 생성
  static Future<String> generateEmotionInsight(List<Map<String, dynamic>> diaryEntries, String periodType) async {
    try {
      // 일기 내용 요약 준비
      String diariesSummary = '';
      for (var entry in diaryEntries) {
        final date = entry['date'] as String;
        final emotion = entry['emotion'] as String;
        final keywords = entry['keywords'] as List<String>;
        diariesSummary += '- 날짜: $date, 감정: $emotion, 키워드: ${keywords.join(', ')}\n';
      }

      String periodText = periodType == 'weekly' ? '주간' : periodType == 'monthly' ? '월간' : '전체 기간';

      final prompt = '''
당신은 친절하고 공감 능력이 뛰어난 심리 상담 전문가입니다.
사용자의 $periodText 일기 데이터를 분석하여 감정 패턴과 인사이트를 제공해주세요.

일기 데이터:
$diariesSummary

다음 지침을 따라 인사이트를 작성해주세요:
1. 3-4문장으로 간결하게 작성
2. 긍정적이고 공감적인 어조 사용
3. 감정 패턴이나 변화에 대한 관찰 포함
4. 실용적인 조언이나 격려의 메시지 포함
5. 따뜻하고 친근한 말투 사용

인사이트만 출력하고 다른 설명은 필요 없습니다.
''';

      final content = [Content.text(prompt)];
      final response = await _textModel.generateContent(content);

      return response.text ?? '이번 ${periodText}에는 다양한 감정을 경험하셨네요. 자신의 감정을 인식하고 기록하는 것만으로도 큰 의미가 있습니다.';
    } catch (e) {
      if (kDebugMode) print('감정 인사이트 생성 오류: $e');
      return '이번 기간 동안의 감정 여정을 함께 기록해주셔서 감사합니다.';
    }
  }
}