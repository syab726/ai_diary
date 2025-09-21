import 'dart:developer';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _geminiApiKey = 'AIzaSyB4sTKHWNsKq_k-X-jlm5l_9BCQC4eq-hc';
  static const String _openaiApiKey = 'sk-proj-YOUR_OPENAI_API_KEY'; // OpenAI API 키를 여기에 입력하세요
  static const String _huggingFaceApiKey = 'hf_YOUR_API_KEY'; // Hugging Face API 키 (무료 가입 후 발급)
  static late GenerativeModel _textModel;
  static late GenerativeModel _imageModel;
  
  static void initialize() {
    print('=== AI Service 초기화 ===');
    print('텍스트 모델명: gemini-2.5-flash');
    print('이미지 생성 모델명: gemini-2.5-flash-image-preview');
    print('API 키 설정됨: ${_geminiApiKey.substring(0, 10)}...');

    _textModel = GenerativeModel(
      model: 'gemini-2.5-flash',
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

  static Future<String> generateImagePrompt(String diaryContent, String emotion, List<String> keywords, String style) async {
    try {
      final response = await _textModel.generateContent([
        Content.text('''다음 일기 내용을 바탕으로 이미지 생성 프롬프트를 만들어주세요.
스타일: $style
감정적이고 아름다운 이미지가 되도록 작성해주세요.

일기 내용: $diaryContent
주요 감정: $emotion
키워드: ${keywords.join(', ')}

프롬프트는 영어로 작성하고, 일기의 감정과 내용을 잘 표현하는 따뜻하고 감성적인 이미지가 되도록 해주세요.''')
      ]);
      
      return response.text?.trim() ?? 'A peaceful and emotional illustration';
    } catch (e) {
      log('이미지 프롬프트 생성 오류: $e');
      return 'A peaceful and emotional illustration representing daily life';
    }
  }

  static Future<String?> generateImage(String prompt) async {
    try {
      print('=== Gemini 2.5 Flash Image로 이미지 생성 시작 ===');
      print('프롬프트: $prompt');

      // Gemini 2.5 Flash Image로 이미지 생성
      try {
        print('Gemini 2.5 Flash Image 이미지 생성 시도...');

        final response = await _imageModel.generateContent([
          Content.text('Generate an image: $prompt')
        ]);

        print('Gemini 응답 받음');

        // 응답에서 이미지 데이터 찾기
        if (response.candidates != null && response.candidates!.isNotEmpty) {
          final candidate = response.candidates!.first;
          if (candidate.content?.parts != null) {
            for (final part in candidate.content!.parts) {
              // DataPart인지 확인 (이미지 데이터)
              if (part is DataPart) {
                print('*** Gemini 2.5 Flash Image 이미지 생성 성공! ***');
                final imageData = base64Encode(part.bytes);
                final mimeType = part.mimeType ?? 'image/png';
                final dataUrl = 'data:$mimeType;base64,$imageData';
                print('이미지 데이터 크기: ${part.bytes.length} bytes');
                return dataUrl;
              }
            }
          }
        }

        print('Gemini 응답에 이미지가 없음 - 폴백 방식 사용');
      } catch (e) {
        print('Gemini 이미지 생성 오류: $e');
      }
      
      // 프롬프트를 분석하여 가장 적합한 이미지 키워드 생성
      final smartKeywords = _generateSmartImageKeywords(prompt);
      print('스마트 키워드: $smartKeywords');
      
      // 여러 이미지 소스 시도
      final imageUrl = _selectBestImageUrl(smartKeywords, prompt);
      print('선택된 이미지 URL: $imageUrl');
      
      return imageUrl;
    } catch (e) {
      print('*** 이미지 매칭 오류 ***');
      print('오류: $e');
      
      // 기본 평화로운 이미지 반환
      return 'https://source.unsplash.com/800x600/?peaceful,nature';
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

  static Future<Map<String, dynamic>> processEntry(String diaryContent, String style) async {
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
      final imagePrompt = await generateImagePrompt(diaryContent, emotion, keywords, style);
      print('이미지 프롬프트 결과: $imagePrompt');
      
      // 이미지 생성
      print('이미지 생성 시작...');
      final imageUrl = await generateImage(imagePrompt);
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