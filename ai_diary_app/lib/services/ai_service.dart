import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'dart:math' hide log;
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/image_options.dart';
import '../models/perspective_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../l10n/app_localizations.dart';

class AIService {
  static final String _geminiApiKey = dotenv.env['GEMINI_API_KEY']!;

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

      if (kDebugMode) debugPrint('이미지 파일 저장 완료: $filePath');
      return filePath;
    } catch (e) {
      if (kDebugMode) debugPrint('이미지 파일 저장 오류: $e');
      return '';
    }
  }
  static const String _openaiApiKey = 'sk-proj-YOUR_OPENAI_API_KEY'; // OpenAI API 키를 여기에 입력하세요
  static const String _huggingFaceApiKey = 'hf_YOUR_API_KEY'; // Hugging Face API 키 (무료 가입 후 발급)
  static late GenerativeModel _textModel;
  static late GenerativeModel _imageModel;
  static String _currentImageModel = 'gemini-2.5-flash-image';
  static Timer? _modelCheckTimer; // 주기적 모델 체크용 타이머

  // 사용 가능한 이미지 생성 모델 자동 감지
  static Future<String?> _detectImageModel() async {
    try {
      if (kDebugMode) debugPrint('=== 사용 가능한 Gemini 모델 조회 중... ===');

      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_geminiApiKey'),
      );

      if (response.statusCode != 200) {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }

      // API 응답 구조 검증 (구조 변경 감지)
      if (!response.body.contains('"models"')) {
        // 구조 변경 감지 → Crashlytics에 리포팅
        FirebaseCrashlytics.instance.recordError(
          Exception('Gemini API 응답 구조 변경 감지 - 개발자 확인 필요'),
          StackTrace.current,
          reason: 'Response preview: ${response.body.substring(0, min(500, response.body.length))}',
          fatal: false,
        );

        if (kDebugMode) debugPrint('⚠⚠⚠ API 구조 변경 감지! Crashlytics에 리포팅됨');
        return null; // 기존 모델 유지
      }

      final data = jsonDecode(response.body);
      final models = data['models'] as List;

      if (kDebugMode) debugPrint('총 ${models.length}개 모델 발견');

      // 이미지 생성 가능한 모델 필터링
      final imageModels = models.where((model) {
        final name = model['name'] as String;
        final supportedActions = model['supportedGenerationMethods'] as List?;

        // 'generateContent'를 지원하고 이름에 'image'가 포함된 모델
        return supportedActions?.contains('generateContent') == true &&
               (name.toLowerCase().contains('image') || name.toLowerCase().contains('imagen'));
      }).toList();

      if (kDebugMode) {
        debugPrint('이미지 생성 가능 모델:');
        for (var model in imageModels) {
          final modelName = (model['name'] as String).replaceAll('models/', '');
          debugPrint('  - $modelName');
        }
      }

      // 첫 번째 이미지 모델 사용 (가장 최신 모델)
      if (imageModels.isNotEmpty) {
        final selectedModel = (imageModels.first['name'] as String).replaceAll('models/', '');
        if (kDebugMode) debugPrint('✓ 선택된 이미지 모델: $selectedModel');
        return selectedModel;
      }

      if (kDebugMode) debugPrint('⚠ 사용 가능한 이미지 모델 없음');
      return null;

    } catch (e, stackTrace) {
      // 모든 에러를 Crashlytics에 리포팅
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Gemini 모델 감지 실패',
        fatal: false,
      );

      if (kDebugMode) debugPrint('모델 조회 실패: $e');
      return null; // 기존 모델 유지
    }
  }

  // 네트워크 연결 확인
  static Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // 모델 감지 및 업데이트
  static Future<void> _detectAndUpdateModel() async {
    try {
      final newModel = await _detectImageModel();

      if (newModel != null && newModel != _currentImageModel) {
        if (kDebugMode) debugPrint('✓ 모델 자동 변경: $_currentImageModel → $newModel');
        _currentImageModel = newModel;

        // 모델 객체 재생성
        _imageModel = GenerativeModel(
          model: _currentImageModel,
          apiKey: _geminiApiKey
        );
      }
    } catch (e, stackTrace) {
      // 실패 시 Crashlytics에 리포팅
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: '모델 자동 감지/업데이트 실패',
        fatal: false,
      );

      if (kDebugMode) debugPrint('모델 체크 실패 (기존 모델 유지): $e');
    }
  }

  // 주기적 모델 체크 시작 (1시간마다)
  static void _startPeriodicModelCheck() {
    _modelCheckTimer = Timer.periodic(Duration(hours: 1), (_) async {
      // 네트워크 없으면 스킵
      if (!await _hasInternetConnection()) {
        if (kDebugMode) debugPrint('네트워크 없음, 모델 체크 스킵');
        return;
      }

      if (kDebugMode) debugPrint('=== 주기적 모델 체크 (1시간마다) ===');
      await _detectAndUpdateModel();
    });

    if (kDebugMode) debugPrint('✓ 주기적 모델 체크 시작 (1시간마다)');
  }

  // 리소스 정리
  static void dispose() {
    _modelCheckTimer?.cancel();
    _modelCheckTimer = null;
    if (kDebugMode) debugPrint('✓ AIService 리소스 정리 완료');
  }

  static Future<void> initialize() async {
    if (kDebugMode) debugPrint('=== AI Service 초기화 ===');
    if (kDebugMode) debugPrint('API 키 설정됨: ${_geminiApiKey.substring(0, 10)}...');

    // 텍스트 모델 초기화
    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _geminiApiKey
    );
    if (kDebugMode) debugPrint('텍스트 모델: gemini-2.0-flash-lite');

    // 이미지 생성 모델 자동 감지
    await _detectAndUpdateModel();

    if (kDebugMode) debugPrint('✓ 이미지 생성 모델: $_currentImageModel');

    // 주기적 모델 체크 시작
    _startPeriodicModelCheck();

    if (kDebugMode) debugPrint('모델 초기화 완료');
  }

  static Future<String> analyzeEmotion(BuildContext context, String diaryContent) async {
    try {
      final l10n = AppLocalizations.of(context);
      final response = await _textModel.generateContent([
        Content.text(l10n.aiEmotionAnalysisPrompt(diaryContent))
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
  static Future<String> analyzePhotos(BuildContext context, List<String> photoPaths) async {
    if (photoPaths.isEmpty) return '';

    try {
      if (kDebugMode) debugPrint('=== 사진 분석 시작 ===');
      if (kDebugMode) debugPrint('분석할 사진 개수: ${photoPaths.length}');

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
            if (kDebugMode) debugPrint('사진 로드 성공: $photoPath');
          }
        } catch (e) {
          if (kDebugMode) debugPrint('사진 로드 실패: $photoPath - $e');
        }
      }

      if (parts.isEmpty) {
        debugPrint('분석 가능한 사진이 없습니다');
        return '';
      }

      // 분석 프롬프트 추가
      final l10n = AppLocalizations.of(context);
      parts.add(TextPart(l10n.aiPhotoAnalysisPrompt));

      final response = await visionModel.generateContent([Content.multi(parts)]);
      final analysisResult = response.text?.trim() ?? '';

      if (kDebugMode) debugPrint('사진 분석 결과: $analysisResult');
      return analysisResult;
    } catch (e) {
      if (kDebugMode) debugPrint('사진 분석 오류: $e');
      return '';
    }
  }

  static Future<String> generateImagePrompt(BuildContext context, String diaryContent, String emotion, List<String> keywords, String style, [AdvancedImageOptions? advancedOptions, PerspectiveOptions? perspectiveOptions, ImageTime? imageTime, ImageWeather? imageWeather, String? photoAnalysis]) async {
    try {
      final l10n = AppLocalizations.of(context);

      // 고급 옵션을 프롬프트 접미사로 변환
      final advancedSuffix = advancedOptions?.generatePromptSuffix() ?? '';
      // 시점 옵션을 프롬프트 접미사로 변환
      final perspectiveSuffix = perspectiveOptions?.getPromptSuffix() ?? '';
      // 시간과 날씨 정보
      final timeSuffix = imageTime != null ? '시간: ${imageTime.displayName}' : '';
      final weatherSuffix = imageWeather != null ? '날씨: ${imageWeather.displayName}' : '';
      // 사진 분석 결과
      final photoSuffix = photoAnalysis != null && photoAnalysis.isNotEmpty ? '사진 분석: $photoAnalysis' : '';

      // 고급 옵션들을 하나의 문자열로 조합
      List<String> advancedParts = [];

      // 중간 부분: 옵션 값들
      if (advancedSuffix.isNotEmpty) {
        advancedParts.add('고급 옵션: $advancedSuffix');
      }
      if (perspectiveSuffix.isNotEmpty) {
        advancedParts.add('시점: $perspectiveSuffix');
      }
      if (timeSuffix.isNotEmpty) {
        advancedParts.add(timeSuffix);
      }
      if (weatherSuffix.isNotEmpty) {
        advancedParts.add(weatherSuffix);
      }
      if (photoSuffix.isNotEmpty) {
        advancedParts.add(photoSuffix);
        advancedParts.add('\n위 사진의 분위기, 색감, 시간대, 장소를 참고해서 일관성 있는 이미지를 생성해주세요.');
      }

      // 하단 부분: 추가 설명들
      if (advancedSuffix.isNotEmpty) {
        advancedParts.add('고급 옵션에서 지정된 조명, 분위기, 색상, 구도 요소들을 반영해주세요.');
      }
      if (perspectiveSuffix.isNotEmpty) {
        advancedParts.add('시점 옵션에서 지정된 관점을 반영해주세요.');
      }
      if (imageTime != null) {
        advancedParts.add('지정된 시간대 ${imageTime.displayName}의 분위기를 반영해주세요.');
      }
      if (imageWeather != null) {
        advancedParts.add('지정된 날씨 ${imageWeather.displayName}의 느낌을 표현해주세요.');
      }
      if (photoAnalysis != null && photoAnalysis.isNotEmpty) {
        advancedParts.add('업로드된 사진의 스타일과 분위기를 최대한 반영해주세요.');
      }

      String advancedCombined = advancedParts.isEmpty ? '' : '\n' + advancedParts.join('\n');

      final response = await _textModel.generateContent([
        Content.text(l10n.aiImagePromptBase(
          style: style,
          content: diaryContent,
          emotion: emotion,
          keywords: keywords.join(', '),
          advanced: advancedCombined,
        ))
      ]);

      return response.text?.trim() ?? 'A peaceful and emotional illustration';
    } catch (e) {
      log('이미지 프롬프트 생성 오류: $e');
      return 'A peaceful and emotional illustration representing daily life';
    }
  }

  static Future<String?> generateImage(String prompt, [ImageTime? imageTime, ImageWeather? imageWeather]) async {
    final startTime = DateTime.now(); // 시간 측정 시작
    try {
      if (kDebugMode) debugPrint('=== Gemini Imagen API를 통한 이미지 생성 시작 ===');
      if (kDebugMode) debugPrint('프롬프트: $prompt');
      if (kDebugMode) debugPrint('적용할 시간: ${imageTime != null ? imageTime.displayName : '기본값'}');
      if (kDebugMode) debugPrint('적용할 날씨: ${imageWeather != null ? imageWeather.displayName : '기본값'}');

      try {
        if (kDebugMode) debugPrint('Gemini 2.5 Flash Image Preview 이미지 생성 시도...');

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

        if (kDebugMode) debugPrint('최종 강화된 프롬프트: $enhancedPrompt');

        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_currentImageModel:generateContent?key=$_geminiApiKey'),
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
              'response_modalities': ['IMAGE'],
            }
          }),
        );

        if (kDebugMode) debugPrint('Gemini Imagen API 응답 상태: ${response.statusCode}');
        if (kDebugMode) debugPrint('Gemini Imagen API 응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // 응답에서 이미지 데이터 찾기
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            final candidate = data['candidates'][0];
            if (candidate['content'] != null && candidate['content']['parts'] != null) {
              for (final part in candidate['content']['parts']) {
                if (part['inlineData'] != null) {
                  final endTime = DateTime.now();
                  final duration = endTime.difference(startTime).inSeconds;
                  debugPrint('*** Gemini 2.5 Flash Image API 이미지 생성 성공! (소요 시간: $duration초) ***');
                  final imageData = part['inlineData']['data'];
                  final mimeType = part['inlineData']['mimeType'] ?? 'image/png';
                  if (kDebugMode) debugPrint('이미지 데이터 크기: ${imageData.length} characters');

                  // 이미지를 파일로 저장
                  final filePath = await _saveImageToFile(imageData, mimeType);
                  if (filePath.isNotEmpty) {
                    debugPrint('파일 저장 성공, 경로 반환: $filePath');
                    return 'file://$filePath';
                  } else {
                    if (kDebugMode) debugPrint('파일 저장 실패, base64 데이터 반환');
                    return 'data:image/png;base64,$imageData';
                  }
                }
              }
            }
          }
        } else {
          if (kDebugMode) debugPrint('Gemini Imagen API 오류: ${response.statusCode} - ${response.body}');
        }

        if (kDebugMode) debugPrint('Gemini Imagen API에서 이미지를 생성하지 못함');
      } catch (e) {
        if (kDebugMode) debugPrint('Gemini Imagen API 호출 오류: $e');
      }

      // AI 이미지 생성 실패 시 null 반환 (외부 서비스 의존성 제거)
      if (kDebugMode) debugPrint('AI 이미지 생성 실패');
      return null;

    } catch (e) {
      if (kDebugMode) debugPrint('*** 이미지 생성 실패 ***');
      if (kDebugMode) debugPrint('오류: $e');
      rethrow;
    }
  }
  

  static Future<Map<String, dynamic>> autoConfigureOptions(String diaryContent) async {
    try {
      if (kDebugMode) debugPrint('=== AI 자동 설정 시작 ===');
      if (kDebugMode) debugPrint('일기 내용: $diaryContent');

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
      if (kDebugMode) debugPrint('AI 응답: $responseText');

      // JSON 파싱 시도
      try {
        // 응답에서 JSON 부분만 추출
        final jsonStart = responseText.indexOf('{');
        final jsonEnd = responseText.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = responseText.substring(jsonStart, jsonEnd + 1);
          final Map<String, dynamic> aiOptions = jsonDecode(jsonString);

          if (kDebugMode) debugPrint('파싱된 AI 옵션: $aiOptions');
          return aiOptions;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('JSON 파싱 오류: $e');
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
      if (kDebugMode) debugPrint('AI 자동 설정 오류: $e');
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
    BuildContext context,
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
      if (kDebugMode) debugPrint('=== AI 처리 시작 ===');
      if (kDebugMode) debugPrint('일기 내용: $diaryContent');
      if (kDebugMode) debugPrint('스타일: $style');
      if (kDebugMode) debugPrint('시간 설정: ${imageTime != null ? imageTime.displayName : '기본값'}');
      if (kDebugMode) debugPrint('날씨 설정: ${imageWeather != null ? imageWeather.displayName : '기본값'}');
      if (kDebugMode) debugPrint('고급 옵션: ${advancedOptions != null ? '활성화' : '비활성화'}');
      if (kDebugMode) debugPrint('시점 옵션: ${perspectiveOptions != null ? '활성화' : '비활성화'}');
      if (kDebugMode) debugPrint('사용자 사진: ${userPhotos != null && userPhotos.isNotEmpty ? '${userPhotos.length}장' : '없음'}');

      // 사진 분석 (있으면)
      String photoAnalysis = '';
      if (userPhotos != null && userPhotos.isNotEmpty) {
        debugPrint('사용자 업로드 사진 분석 시작...');
        photoAnalysis = await analyzePhotos(context, userPhotos);
        if (kDebugMode) debugPrint('사진 분석 완료: $photoAnalysis');
      }

      // 병렬로 감정 분석과 키워드 추출 실행
      if (kDebugMode) debugPrint('감정 분석 및 키워드 추출 시작...');
      final futures = await Future.wait([
        analyzeEmotion(context, diaryContent),
        extractKeywords(diaryContent),
      ]);

      final emotion = futures[0] as String;
      final keywords = futures[1] as List<String>;

      if (kDebugMode) debugPrint('감정 분석 결과: $emotion');
      if (kDebugMode) debugPrint('키워드 추출 결과: $keywords');

      // 이미지 프롬프트 생성 (사진 분석 결과 포함)
      if (kDebugMode) debugPrint('이미지 프롬프트 생성 시작...');
      final imagePrompt = await generateImagePrompt(
        context,
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
      if (kDebugMode) debugPrint('이미지 프롬프트 결과: $imagePrompt');

      // 이미지 생성
      if (kDebugMode) debugPrint('이미지 생성 시작...');
      final imageUrl = await generateImage(imagePrompt, imageTime, imageWeather);
      if (kDebugMode) debugPrint('이미지 생성 완료. URL: $imageUrl');

      final result = {
        'emotion': emotion,
        'keywords': keywords,
        'imagePrompt': imagePrompt,
        'imageUrl': imageUrl,
      };

      if (kDebugMode) debugPrint('=== AI 처리 완료 ===');
      if (kDebugMode) debugPrint('최종 결과: $result');

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('AI 처리 오류: $e');
      if (kDebugMode) debugPrint('스택 트레이스: $stackTrace');
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
  static Future<String> generateEmotionInsight(BuildContext context, List<Map<String, dynamic>> diaryEntries, String periodType) async {
    final l10n = AppLocalizations.of(context);
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

      final prompt = l10n.aiEmotionInsightSystem(
        period: periodText,
        diaries: diariesSummary,
      );

      final content = [Content.text(prompt)];
      final response = await _textModel.generateContent(content);

      return response.text ?? l10n.aiDefaultInsight(periodText);
    } catch (e) {
      if (kDebugMode) debugPrint('감정 인사이트 생성 오류: $e');
      return l10n.aiFallbackInsight;
    }
  }
}