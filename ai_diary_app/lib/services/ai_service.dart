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
import '../models/image_ratio.dart';

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

  static Future<String> generateImagePrompt(String diaryContent, String emotion, List<String> keywords, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageRatio? imageRatio]) async {
    try {
      // 고급 옵션을 프롬프트 접미사로 변환
      final advancedSuffix = advancedOptions?.generatePromptSuffix() ?? '';
      // 시점 옵션을 프롬프트 접미사로 변환
      final perspectiveSuffix = perspectiveOptions?.getPromptSuffix() ?? '';
      // 이미지 비율 정보
      final ratioSuffix = imageRatio != null ? '이미지 비율: ${imageRatio.ratio} (${imageRatio.displayName})' : '';

      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용을 바탕으로 이미지 생성 프롬프트를 만들어주세요.
스타일: $style
감정적이고 아름다운 이미지가 되도록 작성해주세요.

일기 내용: $diaryContent
주요 감정: $emotion
키워드: ${keywords.join(', ')}
${advancedSuffix.isNotEmpty ? '고급 옵션: $advancedSuffix' : ''}
${perspectiveSuffix.isNotEmpty ? '시점: $perspectiveSuffix' : ''}
${ratioSuffix.isNotEmpty ? '이미지 비율: $ratioSuffix' : ''}

프롬프트는 영어로 작성하고, 일기의 감정과 내용을 잘 표현하는 따뜻하고 감성적인 이미지가 되도록 해주세요.
${advancedSuffix.isNotEmpty ? '고급 옵션에서 지정된 조명, 분위기, 색상, 구도 요소들을 반영해주세요.' : ''}
${perspectiveSuffix.isNotEmpty ? '시점 옵션에서 지정된 관점을 반영해주세요.' : ''}
${ratioSuffix.isNotEmpty ? '지정된 이미지 비율 ${imageRatio!.ratio}에 맞춰서 이미지를 생성해주세요.' : ''}''')
      ]);
      
      return response.text?.trim() ?? 'A peaceful and emotional illustration';
    } catch (e) {
      log('이미지 프롬프트 생성 오류: $e');
      return 'A peaceful and emotional illustration representing daily life';
    }
  }

  static Future<String?> generateImage(String prompt, [ImageRatio? imageRatio]) async {
    try {
      print('=== Gemini Imagen API를 통한 이미지 생성 시작 ===');
      print('프롬프트: $prompt');

      try {
        print('Gemini 2.5 Flash Image Preview 이미지 생성 시도...');

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
                    'text': 'Generate an image with aspect ratio ${imageRatio?.ratio ?? "1:1"}: $prompt'
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

      throw Exception('Gemini Imagen 이미지 생성 실패');

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
    
    // 다양한 이미지 소스 중에서 선택
    final sources = [
      'https://source.unsplash.com/800x600/?$searchTerm',
      'https://picsum.photos/800/600?random=${DateTime.now().millisecondsSinceEpoch}',
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

  static Future<Map<String, dynamic>> processEntry(String diaryContent, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageRatio? imageRatio]) async {
    try {
      print('=== AI 처리 시작 ===');
      print('일기 내용: $diaryContent');
      print('스타일: $style');
      
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
      final imagePrompt = await generateImagePrompt(diaryContent, emotion, keywords, style, advancedOptions, perspectiveOptions, imageRatio);
      print('이미지 프롬프트 결과: $imagePrompt');
      
      // 이미지 생성
      print('이미지 생성 시작...');
      final imageUrl = await generateImage(imagePrompt, imageRatio);
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
      return {
        'emotion': 'peaceful',
        'keywords': <String>[],
        'imagePrompt': 'A peaceful illustration',
        'imageUrl': 'https://picsum.photos/400/300?random=error',
      };
    }
  }
}