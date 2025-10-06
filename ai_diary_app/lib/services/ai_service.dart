import 'dart:developer';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/image_options.dart';
import '../models/perspective_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';

class AIService {
  static const String _geminiApiKey = 'AIzaSyB4sTKHWNsKq_k-X-jlm5l_9BCQC4eq-hc';

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

      print('이미지 파일 저장 완료: $filePath');
      return filePath;
    } catch (e) {
      print('이미지 파일 저장 오류: $e');
      return '';
    }
  }
  static const String _openaiApiKey = 'sk-proj-YOUR_OPENAI_API_KEY'; // OpenAI API 키를 여기에 입력하세요
  static const String _huggingFaceApiKey = 'hf_YOUR_API_KEY'; // Hugging Face API 키 (무료 가입 후 발급)
  static late GenerativeModel _textModel;
  static late GenerativeModel _imageModel;
  
  static void initialize() {
    print('=== AI Service 초기화 ===');
    print('텍스트 모델명: gemini-2.0-flash-lite');
    print('이미지 생성 모델명: gemini-2.5-flash-image-preview');
    print('API 키 설정됨: ${_geminiApiKey.substring(0, 10)}...');

    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _geminiApiKey
    );
    _imageModel = GenerativeModel(
      model: 'gemini-2.5-flash-image-preview',
      apiKey: _geminiApiKey
    );

    print('모델 초기화 완료');
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

  static Future<String> generateImagePrompt(String diaryContent, String emotion, List<String> keywords, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageTime? imageTime, ImageWeather? imageWeather]) async {
    try {
      // 고급 옵션을 프롬프트 접미사로 변환
      final advancedSuffix = advancedOptions?.generatePromptSuffix() ?? '';
      // 시점 옵션을 프롬프트 접미사로 변환
      final perspectiveSuffix = perspectiveOptions?.getPromptSuffix() ?? '';
      // 시간과 날씨 정보
      final timeSuffix = imageTime != null ? '시간: ${imageTime.displayName}' : '';
      final weatherSuffix = imageWeather != null ? '날씨: ${imageWeather.displayName}' : '';

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

프롬프트는 영어로 작성하고, 일기의 감정과 내용을 잘 표현하는 따뜻하고 감성적인 이미지가 되도록 해주세요.
${advancedSuffix.isNotEmpty ? '고급 옵션에서 지정된 조명, 분위기, 색상, 구도 요소들을 반영해주세요.' : ''}
${perspectiveSuffix.isNotEmpty ? '시점 옵션에서 지정된 관점을 반영해주세요.' : ''}
${timeSuffix.isNotEmpty ? '지정된 시간대 ${imageTime!.displayName}의 분위기를 반영해주세요.' : ''}
${weatherSuffix.isNotEmpty ? '지정된 날씨 ${imageWeather!.displayName}의 느낌을 표현해주세요.' : ''}''')
      ]);
      
      return response.text?.trim() ?? 'A peaceful and emotional illustration';
    } catch (e) {
      log('이미지 프롬프트 생성 오류: $e');
      return 'A peaceful and emotional illustration representing daily life';
    }
  }

  static Future<String?> generateImage(String prompt, [ImageTime? imageTime, ImageWeather? imageWeather]) async {
    try {
      print('=== Gemini Imagen API를 통한 이미지 생성 시작 ===');
      print('프롬프트: $prompt');
      print('적용할 시간: ${imageTime != null ? imageTime.displayName : '기본값'}');
      print('적용할 날씨: ${imageWeather != null ? imageWeather.displayName : '기본값'}');

      try {
        print('Gemini 2.5 Flash Image Preview 이미지 생성 시도...');

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

        print('최종 강화된 프롬프트: $enhancedPrompt');

        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent?key=$_geminiApiKey'),
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

        print('Gemini Imagen API 응답 상태: ${response.statusCode}');
        print('Gemini Imagen API 응답 본문: ${response.body}');

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
                  print('이미지 데이터 크기: ${imageData.length} characters');

                  // 이미지를 파일로 저장
                  final filePath = await _saveImageToFile(imageData, mimeType);
                  if (filePath.isNotEmpty) {
                    print('파일 저장 성공, 경로 반환: $filePath');
                    return 'file://$filePath';
                  } else {
                    print('파일 저장 실패, base64 데이터 반환');
                    return 'data:image/png;base64,$imageData';
                  }
                }
              }
            }
          }
        } else {
          print('Gemini Imagen API 오류: ${response.statusCode} - ${response.body}');
        }

        print('Gemini Imagen API에서 이미지를 생성하지 못함');
      } catch (e) {
        print('Gemini Imagen API 호출 오류: $e');
      }

      // Gemini API 실패시 폴백으로 Unsplash/Picsum 사용
      print('폴백: Unsplash/Picsum 이미지 사용');
      final smartKeywords = _generateSmartImageKeywords(prompt);
      final fallbackImageUrl = _selectBestImageUrl(smartKeywords, prompt);
      print('폴백 이미지 URL: $fallbackImageUrl');
      return fallbackImageUrl;

    } catch (e) {
      print('*** 이미지 생성 실패 ***');
      print('오류: $e');
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

    print('선택된 이미지 크기: $dimensions');

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
      print('=== AI 자동 설정 시작 ===');
      print('일기 내용: $diaryContent');

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
      print('AI 응답: $responseText');

      // JSON 파싱 시도
      try {
        // 응답에서 JSON 부분만 추출
        final jsonStart = responseText.indexOf('{');
        final jsonEnd = responseText.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = responseText.substring(jsonStart, jsonEnd + 1);
          final Map<String, dynamic> aiOptions = jsonDecode(jsonString);

          print('파싱된 AI 옵션: $aiOptions');
          return aiOptions;
        }
      } catch (e) {
        print('JSON 파싱 오류: $e');
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
      print('AI 자동 설정 오류: $e');
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

  static Future<Map<String, dynamic>> processEntry(String diaryContent, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageTime? imageTime, ImageWeather? imageWeather]) async {
    try {
      print('=== AI 처리 시작 ===');
      print('일기 내용: $diaryContent');
      print('스타일: $style');
      print('시간 설정: ${imageTime != null ? imageTime.displayName : '기본값'}');
      print('날씨 설정: ${imageWeather != null ? imageWeather.displayName : '기본값'}');
      print('고급 옵션: ${advancedOptions != null ? '활성화' : '비활성화'}');
      print('시점 옵션: ${perspectiveOptions != null ? '활성화' : '비활성화'}');
      
      // 병렬로 감정 분석과 키워드 추출 실행
      print('감정 분석 및 키워드 추출 시작...');
      final futures = await Future.wait([
        analyzeEmotion(diaryContent),
        extractKeywords(diaryContent),
      ]);

      final emotion = futures[0] as String;
      final keywords = futures[1] as List<String>;
      
      print('감정 분석 결과: $emotion');
      print('키워드 추출 결과: $keywords');

      // 이미지 프롬프트 생성
      print('이미지 프롬프트 생성 시작...');
      final imagePrompt = await generateImagePrompt(diaryContent, emotion, keywords, style, advancedOptions, perspectiveOptions, imageTime, imageWeather);
      print('이미지 프롬프트 결과: $imagePrompt');
      
      // 이미지 생성
      print('이미지 생성 시작...');
      final imageUrl = await generateImage(imagePrompt, imageTime, imageWeather);
      print('이미지 생성 완료. URL: $imageUrl');

      final result = {
        'emotion': emotion,
        'keywords': keywords,
        'imagePrompt': imagePrompt,
        'imageUrl': imageUrl,
      };
      
      print('=== AI 처리 완료 ===');
      print('최종 결과: $result');
      
      return result;
    } catch (e, stackTrace) {
      print('AI 처리 오류: $e');
      print('스택 트레이스: $stackTrace');
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
      print('감정 인사이트 생성 오류: $e');
      return '이번 기간 동안의 감정 여정을 함께 기록해주셔서 감사합니다.';
    }
  }
}