import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/diary_entry.dart';
import '../models/image_style.dart';
import '../models/image_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import '../models/perspective_options.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/ad_service.dart';
import '../services/free_user_service.dart';
import '../providers/diary_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/image_style_provider.dart';
import '../widgets/image_viewer.dart';
import '../widgets/tabbed_option_selector.dart';
import '../providers/font_provider.dart';
import '../providers/auto_advanced_settings_provider.dart';
import '../models/font_family.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DiaryCreateScreen extends ConsumerStatefulWidget {
  final String? existingDiaryId;

  const DiaryCreateScreen({
    super.key,
    this.existingDiaryId,
  });

  @override
  ConsumerState<DiaryCreateScreen> createState() => _DiaryCreateScreenState();
}

class _DiaryCreateScreenState extends ConsumerState<DiaryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;
  bool _isGeneratingImage = false;
  bool _isPickingImage = false;
  String? _generatedImageUrl;
  String _progressMessage = '';
  DiaryEntry? _existingEntry;
  AdvancedImageOptions _advancedOptions = const AdvancedImageOptions();
  ImageTime _selectedTime = ImageTime.morning;
  ImageWeather _selectedWeather = ImageWeather.sunny;
  ImageSeason _selectedSeason = ImageSeason.spring;
  PerspectiveOptions _perspectiveOptions = const PerspectiveOptions();
  String? _selectedThemePresetId;
  FontFamily _selectedFont = FontFamily.notoSans;
  ImageStyle _selectedImageStyle = ImageStyle.illustration;
  bool _isAutoConfigEnabled = false;

  // 사진 업로드 관련
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedPhotos = [];
  final _photoExpansionController = ExpansionTileController();


  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingEntry() async {
    if (widget.existingDiaryId != null) {
      try {
        print('DiaryCreateScreen: 기존 일기 ID로 로딩 시작: ${widget.existingDiaryId}');
        final entry = await DatabaseService.getDiaryById(widget.existingDiaryId!);
        if (entry != null) {
          print('DiaryCreateScreen: 기존 일기 로딩 성공: ${entry.title}');
          setState(() {
            _existingEntry = entry;
            _titleController.text = entry.title;
            _contentController.text = entry.content;
            _generatedImageUrl = entry.generatedImageUrl;
            _selectedFont = entry.fontFamily;
            _selectedImageStyle = entry.imageStyle;
            _selectedTime = entry.imageTime;
            _selectedWeather = entry.imageWeather;
            _selectedSeason = entry.imageSeason;
            _selectedPhotos = List.from(entry.userPhotos);
          });
        } else {
          print('DiaryCreateScreen: 기존 일기를 찾을 수 없음');
        }
      } catch (e) {
        print('DiaryCreateScreen: 기존 일기 로딩 오류: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('일기를 불러오는데 실패했습니다: $e')),
          );
        }
      }
    }
  }

  bool get _isEditMode => _existingEntry != null;


  /// ============== Phase 3: 하이브리드 프리미엄 모델 ==============
  ///
  /// 무료 사용자: 5개 완전 무료 → 이후 매일 3개 (광고 시청 필요)
  /// 프리미엄 사용자: 무제한 생성
  Future<void> _generateDiary() async {
    // Step 1: 폼 검증
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);
    final freeUserService = FreeUserService();

    // Step 2: 프리미엄 사용자는 바로 생성
    if (subscription.isPremium) {
      print('[하이브리드 모델] 프리미엄 사용자 - 광고 없이 바로 생성');
      await _createDiary();
      return;
    }

    // Step 3: 무료 사용자 - 최초 5개는 완전 무료
    List<DiaryEntry> allDiaries = [];
    try {
      allDiaries = await DatabaseService.getAllDiaries();
      if (allDiaries.length < 5) {
        print('[하이브리드 모델] 최초 5개 무료 생성: ${allDiaries.length + 1}/5');
        await _createDiary();
        return;
      }
    } catch (e) {
      print('[하이브리드 모델] 데이터베이스 오류 - 일기 개수 확인 실패: $e');
      // 데이터베이스 오류 시 광고 시청 경로로 진행
      print('[하이브리드 모델] 안전을 위해 광고 경로로 진행');
    }

    // Step 4: 6번째 일기부터는 일일 카운터 확인
    int dailyAdCount;
    try {
      dailyAdCount = await freeUserService.getDailyAdCount();
      print('[하이브리드 모델] 오늘 광고 시청 횟수: $dailyAdCount/3');
    } catch (e) {
      print('[하이브리드 모델] 카운터 확인 실패: $e');
      _showAdFailedDialog();
      return;
    }

    // Step 5: 일일 제한 도달 시 다이얼로그 표시
    if (dailyAdCount >= 3) {
      print('[하이브리드 모델] 일일 제한 도달 - 내일 00:00 리셋');
      _showDailyLimitDialog();
      return;
    }

    // Step 6: 광고 안내 다이얼로그 표시
    final shouldShowAd = await _showAdExplanationDialog(
      isFirstTime: allDiaries.length == 5, // 6번째 일기인지 확인
      dailyCount: dailyAdCount,
    );

    if (!shouldShowAd) {
      print('[하이브리드 모델] 사용자가 광고 시청 취소');
      return;
    }

    // Step 7: 보상형 광고 표시
    print('[하이브리드 모델] 보상형 광고 표시 시작');
    final adWatched = await AdService().showRewardedAd();

    if (!adWatched) {
      print('[하이브리드 모델] 광고 로드 실패 또는 시청 중단');
      _showAdFailedDialog();
      return;
    }

    // 광고 시청 성공 - 카운터 증가
    print('[하이브리드 모델] 광고 시청 완료 - 카운터 증가');
    try {
      final newCount = await freeUserService.incrementAdCount();
      print('[하이브리드 모델] 업데이트된 카운터: $newCount/3');
    } catch (e) {
      print('[하이브리드 모델] 카운터 증가 실패 (계속 진행): $e');
      // 카운터 증가 실패해도 일기 생성은 허용 (사용자가 광고를 시청했으므로)
    }

    // 성공 애니메이션 표시
    _showAdCompletionAnimation();
    await Future.delayed(const Duration(milliseconds: 800));

    // 일기 생성 시작
    await _createDiary();
  }

  /// 실제 일기 생성 로직 (프리미엄/무료 모두 사용)
  Future<void> _createDiary() async {
    print('=== _createDiary 시작 ===');
    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
      _progressMessage = _selectedPhotos.isNotEmpty ? '사진 분석 중...' : '감정 분석 중...';
      print('_isGeneratingImage = true 설정됨');
    });

    try {
      final subscription = ref.read(subscriptionProvider);
      final selectedStyle = ref.read(defaultImageStyleProvider);

      AdvancedImageOptions effectiveAdvancedOptions = _advancedOptions;
      ImageTime effectiveTime = _selectedTime;
      ImageWeather effectiveWeather = _selectedWeather;

      // 단계별 프로그레스 메시지 업데이트
      if (_selectedPhotos.isNotEmpty) {
        setState(() => _progressMessage = '사진 분위기 분석 중...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() => _progressMessage = '감정 분석 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = '키워드 추출 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = '이미지 프롬프트 생성 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = 'AI 이미지 생성 중...');

      // AI 서비스를 통한 이미지 생성
      final Map<String, dynamic> result = await AIService.processEntry(
        _contentController.text.trim(),
        selectedStyle.displayName,
        subscription.isPremium ? effectiveAdvancedOptions : null,
        _perspectiveOptions,
        subscription.isPremium ? effectiveTime : null,
        subscription.isPremium ? effectiveWeather : null,
        subscription.isPremium ? _selectedSeason : null,
        subscription.isPremium && _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );

      final imageUrl = result['imageUrl'] as String?;
      final emotion = result['emotion'] as String?;
      final keywords = List<String>.from(result['keywords'] as List? ?? []);
      final aiPrompt = result['imagePrompt'] as String?;

      // imageUrl에서 바이너리 데이터 추출
      Uint8List? imageData;
      if (imageUrl != null) {
        try {
          if (imageUrl.startsWith('file://')) {
            // file:// 경로에서 파일 읽기
            final filePath = imageUrl.replaceFirst('file://', '');
            final file = File(filePath);
            if (await file.exists()) {
              imageData = await file.readAsBytes();
              print('파일에서 이미지 데이터 로드 성공: ${imageData.length} bytes');
            }
          } else if (imageUrl.startsWith('data:image/')) {
            // base64 데이터에서 디코드
            final base64Data = imageUrl.split(',')[1];
            imageData = base64Decode(base64Data);
            print('base64에서 이미지 데이터 디코드 성공: ${imageData.length} bytes');
          } else if (imageUrl.startsWith('/')) {
            // 절대 경로에서 파일 읽기
            final file = File(imageUrl);
            if (await file.exists()) {
              imageData = await file.readAsBytes();
              print('절대경로 파일에서 이미지 데이터 로드 성공: ${imageData.length} bytes');
            }
          }
        } catch (e) {
          print('이미지 데이터 추출 오류: $e');
        }
      }

      final diary = DiaryEntry(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        generatedImageUrl: imageUrl,
        imageData: imageData,
        emotion: emotion,
        keywords: keywords,
        aiPrompt: aiPrompt,
        imageStyle: selectedStyle,
        fontFamily: _selectedFont,
        imageTime: _selectedTime,
        imageWeather: _selectedWeather,
        imageSeason: _selectedSeason,
        userPhotos: _selectedPhotos,
      );

      String diaryId;
      if (_existingEntry != null) {
        final updatedDiary = diary.copyWith(
          id: _existingEntry!.id,
          createdAt: _existingEntry!.createdAt,
          updatedAt: DateTime.now(),
        );
        await DatabaseService.updateDiary(updatedDiary);
        diaryId = _existingEntry!.id;
      } else {
        diaryId = await DatabaseService.insertDiary(diary);
      }

      // Diary Provider 업데이트
      ref.invalidate(diaryEntriesProvider);

      setState(() {
        _generatedImageUrl = imageUrl;
        _isLoading = false;
        _isGeneratingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기가 성공적으로 저장되었습니다!')),
        );
        context.go('/detail/$diaryId');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isGeneratingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  Future<void> _saveTextOnly() async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    setState(() {
      _isLoading = true;
    });

    try {
      String diaryId;
      if (_existingEntry != null) {
        // 무료 사용자는 기존 사진 유지, 프리미엄 사용자는 수정 가능
        final userPhotos = subscription.isPremium
            ? _selectedPhotos
            : _existingEntry!.userPhotos;

        final updatedDiary = DiaryEntry(
          id: _existingEntry!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: _existingEntry!.createdAt,
          updatedAt: DateTime.now(),
          generatedImageUrl: _existingEntry!.generatedImageUrl,
          emotion: _existingEntry!.emotion,
          keywords: _existingEntry!.keywords,
          aiPrompt: _existingEntry!.aiPrompt,
          imageStyle: _existingEntry!.imageStyle,
          fontFamily: _selectedFont,
          imageTime: _existingEntry!.imageTime,
          imageWeather: _existingEntry!.imageWeather,
          imageSeason: _existingEntry!.imageSeason,
          userPhotos: userPhotos,
        );
        await DatabaseService.updateDiary(updatedDiary);
        diaryId = _existingEntry!.id;
      } else {
        final diary = DiaryEntry(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          generatedImageUrl: null,
          emotion: null,
          keywords: [],
          aiPrompt: null,
          imageStyle: ImageStyle.realistic,
          fontFamily: _selectedFont,
          imageTime: _selectedTime,
          imageWeather: _selectedWeather,
          imageSeason: _selectedSeason,
          userPhotos: _selectedPhotos,
        );
        diaryId = await DatabaseService.insertDiary(diary);
      }

      // Diary Provider 업데이트
      ref.invalidate(diaryEntriesProvider);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기가 성공적으로 저장되었습니다!')),
        );
        context.go('/detail/$diaryId');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }


  // 선택한 스타일과 옵션으로 이미지 재생성 (프리미엄 전용)
  Future<void> _regenerateImage(ImageStyle style, AdvancedImageOptions advancedOptions) async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    // 무료 사용자는 이미지 재생성 불가 - 프리미엄 안내
    if (!subscription.isPremium) {
      _showPremiumRegenerationDialog();
      return;
    }

    // 프리미엄 사용자는 광고 없이 바로 재생성
    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
      _progressMessage = _selectedPhotos.isNotEmpty ? '사진 분석 중...' : '감정 분석 중...';
    });

    try{
      // 단계별 프로그레스 메시지 업데이트
      if (_selectedPhotos.isNotEmpty) {
        setState(() => _progressMessage = '사진 분위기 분석 중...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() => _progressMessage = '감정 분석 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = '키워드 추출 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = '이미지 프롬프트 생성 중...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _progressMessage = 'AI 이미지 생성 중...');

      // AI 서비스를 통한 이미지 재생성
      final Map<String, dynamic> result = await AIService.processEntry(
        _contentController.text.trim(),
        style.displayName,
        subscription.isPremium ? advancedOptions : null,
        _perspectiveOptions,
        subscription.isPremium ? _selectedTime : null,
        subscription.isPremium ? _selectedWeather : null,
        subscription.isPremium ? _selectedSeason : null,
        subscription.isPremium && _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );

      final newImageUrl = result['imageUrl'] as String?;
      final emotion = result['emotion'] as String?;
      final keywords = List<String>.from(result['keywords'] as List? ?? []);
      final aiPrompt = result['imagePrompt'] as String?;

      // imageUrl에서 바이너리 데이터 추출
      Uint8List? imageData;
      if (newImageUrl != null) {
        try {
          if (newImageUrl.startsWith('file://')) {
            // file:// 경로에서 파일 읽기
            final filePath = newImageUrl.replaceFirst('file://', '');
            final file = File(filePath);
            if (await file.exists()) {
              imageData = await file.readAsBytes();
              print('파일에서 이미지 데이터 로드 성공: ${imageData.length} bytes');
            }
          } else if (newImageUrl.startsWith('data:image/')) {
            // base64 데이터에서 디코드
            final base64Data = newImageUrl.split(',')[1];
            imageData = base64Decode(base64Data);
            print('base64에서 이미지 데이터 디코드 성공: ${imageData.length} bytes');
          } else if (newImageUrl.startsWith('/')) {
            // 절대 경로에서 파일 읽기
            final file = File(newImageUrl);
            if (await file.exists()) {
              imageData = await file.readAsBytes();
              print('절대경로 파일에서 이미지 데이터 로드 성공: ${imageData.length} bytes');
            }
          }
        } catch (e) {
          print('이미지 데이터 추출 오류: $e');
        }
      }

      setState(() {
        _generatedImageUrl = newImageUrl;
      });

      // 일기 업데이트 (기존 일기 수정 모드일 때만)
      if (_existingEntry != null) {
        final updatedDiary = DiaryEntry(
          id: _existingEntry!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: _existingEntry!.createdAt,
          updatedAt: DateTime.now(),
          generatedImageUrl: newImageUrl,
          imageData: imageData,
          emotion: emotion,
          keywords: keywords,
          aiPrompt: aiPrompt,
          imageStyle: style,
          fontFamily: _selectedFont,
          hasBeenRegenerated: true,
          imageTime: _selectedTime,
          imageWeather: _selectedWeather,
          imageSeason: _selectedSeason,
          userPhotos: _selectedPhotos,
        );

        await DatabaseService.updateDiary(updatedDiary);

        // 프로바이더 업데이트
        ref.invalidate(diaryEntriesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그림이 재생성되어 저장되었습니다')),
          );

          // 상태 초기화하고 페이지 이동
          setState(() {
            _isLoading = false;
            _isGeneratingImage = false;
          });
          context.go('/detail/${_existingEntry!.id}');
        }
      }
    } catch (e) {
      print('이미지 재생성 오류: $e');
      setState(() {
        _isLoading = false;
        _isGeneratingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('그림 재생성 실패: $e')),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await DatabaseService.deleteDiary(_existingEntry!.id);
                ref.invalidate(diaryEntriesProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일기가 삭제되었습니다.')),
                  );
                  context.go('/list');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildImageWidget(String imageUrl) {
    Widget imageWidget;

    // file:// 경로인 경우 로컬 파일로 처리
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      // 파일이 존재하는지 확인
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('로컬 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } else {
        print('로컬 이미지 파일이 존재하지 않음: $filePath');
        return _buildImagePlaceholder();
      }
    }
    // 절대 경로인 경우 (file:// 접두사 없음)
    else if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);

      // 파일이 존재하는지 확인
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('로컬 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } else {
        print('로컬 이미지 파일이 존재하지 않음: $imageUrl');
        return _buildImagePlaceholder();
      }
    }
    // data: URL인 경우 (base64)
    else if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('base64 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        print('base64 디코딩 오류: $e');
        return _buildImagePlaceholder();
      }
    }
    // HTTP URL인 경우 네트워크 이미지로 처리
    else if (imageUrl.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          print('네트워크 이미지 로드 오류: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    // 알 수 없는 형식
    else {
      print('알 수 없는 이미지 URL 형식: $imageUrl');
      return _buildImagePlaceholder();
    }

    // 이미지를 GestureDetector로 감싸서 클릭 시 ImageViewer로 이동
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewer(
              imageUrl: imageUrl,
              title: _titleController.text.isNotEmpty ? _titleController.text : '생성된 이미지',
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('이미지를 불러올 수 없습니다'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final selectedFont = ref.watch(fontProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? '일기 수정' : '새 일기 작성',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A5568),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF4A5568),
            size: 20,
          ),
          onPressed: () {
            if (_isEditMode) {
              context.go('/detail/${_existingEntry!.id}');
            } else {
              context.go('/list');
            }
          },
        ),
        actions: [
          if (_isEditMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: _showDeleteDialog,
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _progressMessage.isEmpty ? '이미지 생성중입니다' : _progressMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 6.0,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // 제목/내용 입력 영역
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목 입력
                          TextFormField(
                            controller: _titleController,
                            style: selectedFont.getTextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: '제목',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '제목을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 내용 입력
                          TextFormField(
                            controller: _contentController,
                            style: selectedFont.getTextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: '내용',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 8,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '내용을 입력해주세요';
                              }
                              return null;
                            },
                          ),

                          // 생성된 이미지와 사용자 사진 갤러리 표시
                          if (_generatedImageUrl != null || _selectedPhotos.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              '이미지 갤러리',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPreviewImageGallery(),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 사진 업로드 영역 (수정 모드에서 무료 사용자는 숨김)
                  if (!_isEditMode || subscription.isPremium)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          controller: _photoExpansionController,
                          initiallyExpanded: false,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Row(
                            children: [
                              const Icon(Icons.add_photo_alternate, size: 20, color: Color(0xFF667EEA)),
                              const SizedBox(width: 8),
                              const Text(
                                '사진 업로드',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              if (_selectedPhotos.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_selectedPhotos.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667EEA),
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: subscription.isPremium
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subscription.isPremium ? '최대 3장' : '1장',
                                  style: TextStyle(
                                    color: subscription.isPremium
                                        ? Colors.blue[700]
                                        : Colors.orange[700],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 사진 선택 버튼
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _pickPhotos,
                                icon: const Icon(Icons.add_photo_alternate, size: 18),
                                label: const Text('사진 선택'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[50],
                                  foregroundColor: Colors.blue[700],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 12),
                        _selectedPhotos.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '사진을 선택해보세요',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: subscription.isPremium
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        subscription.isPremium
                                            ? '최대 3장까지 업로드 가능'
                                            : '무료 버전: 1장만 선택 가능',
                                        style: TextStyle(
                                          color: subscription.isPremium
                                              ? Colors.blue[700]
                                              : Colors.orange[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedPhotos.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 120,
                                      margin: EdgeInsets.only(
                                        right: index == _selectedPhotos.length - 1 ? 0 : 12,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              File(_selectedPhotos[index]),
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('사진 미리보기 로드 오류: $error');
                                                print('사진 경로: ${_selectedPhotos[index]}');
                                                return Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: Colors.grey[300],
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error_outline, color: Colors.grey[600]),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        '로드 실패',
                                                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          // 배지
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.photo,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '내 사진',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // 삭제 버튼
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () => _removePhoto(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                          ],
                        ),
                      ),
                    ),

                  // 탭 옵션 영역 (조건부 표시)
                  !_isEditMode || subscription.isPremium
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TabbedOptionSelector(
                            isPremium: subscription.isPremium,
                            advancedOptions: _advancedOptions,
                            onAdvancedOptionsChanged: (options) {
                              setState(() {
                                _advancedOptions = options;
                              });
                            },
                            selectedTime: _selectedTime,
                            onTimeChanged: (time) {
                              setState(() {
                                _selectedTime = time;
                              });
                            },
                            selectedWeather: _selectedWeather,
                            onWeatherChanged: (weather) {
                              setState(() {
                                _selectedWeather = weather;
                              });
                            },
                            selectedSeason: _selectedSeason,
                            onSeasonChanged: (season) {
                              setState(() {
                                _selectedSeason = season;
                              });
                            },
                            perspectiveOptions: _perspectiveOptions,
                            onPerspectiveOptionsChanged: (options) {
                              setState(() {
                                _perspectiveOptions = options;
                              });
                            },
                            selectedThemePresetId: _selectedThemePresetId,
                            onThemePresetChanged: (presetId) {
                              setState(() {
                                _selectedThemePresetId = presetId;
                              });
                            },
                            isAutoConfigEnabled: ref.watch(autoAdvancedSettingsProvider),
                            onAutoConfigChanged: (enabled) {
                              ref.read(autoAdvancedSettingsProvider.notifier).setAutoAdvancedSettings(enabled);
                            },
                            onAutoConfigApply: _applyAutoAdvancedSettings,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 48,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '이미지 수정은 프리미엄에서만 제공',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '다양한 그림 스타일과 옵션을 사용하려면\n프리미엄으로 업그레이드하세요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

              // 버튼 영역 - 화면 하단에 고정
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: _isEditMode
                  ? Consumer(
                      builder: (context, ref, child) {
                        final subscriptionNotifier = ref.watch(subscriptionProvider);
                        final isPremium = subscriptionNotifier.isPremium;

                        if (isPremium) {
                          // 프리미엄 사용자: 3개 버튼 (취소/일기만 수정/그림+일기 수정)
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/detail/${_existingEntry!.id}'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Colors.grey),
                                    foregroundColor: Colors.grey,
                                  ),
                                  child: const Text('취소'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saveTextOnly,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xFF667EEA)),
                                    foregroundColor: const Color(0xFF667EEA),
                                  ),
                                  child: const Text('일기만 수정'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _existingEntry?.hasBeenRegenerated == true
                                      ? null
                                      : (_isGeneratingImage ? null : () => _regenerateImage(_selectedImageStyle, _advancedOptions)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _existingEntry?.hasBeenRegenerated == true
                                        ? Colors.grey.shade400
                                        : const Color(0xFF667EEA),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isGeneratingImage
                                      ? const Text(
                                          '생성중...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Text(
                                          _existingEntry?.hasBeenRegenerated == true
                                              ? '재생성 완료'
                                              : '그림+일기 수정',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // 무료 사용자: 2개 버튼 (취소/수정)
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/detail/${_existingEntry!.id}'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Colors.grey),
                                    foregroundColor: Colors.grey,
                                  ),
                                  child: const Text('취소'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: _saveTextOnly,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF667EEA),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('수정'),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/list'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                              foregroundColor: Colors.grey,
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _isGeneratingImage ? null : _generateDiary,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isGeneratingImage
                                ? const Text(
                                    '이미지 생성중...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text('AI 그림일기 생성'),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          ),
    );
  }

  // 고급옵션 자동설정 적용 (조명, 분위기, 색상, 구도만)
  void _applyAutoAdvancedSettings() {
    // 일기 내용을 분석해서 고급옵션 자동 설정
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('일기 내용을 먼저 작성해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // AI 분석 기반 고급옵션 설정 (조명, 분위기, 색상, 구도만)
    setState(() {
      _advancedOptions = AdvancedImageOptions(
        // 조명 설정
        lighting: _getAnalyzedLighting(content),
        // 분위기 설정
        mood: _getAnalyzedMood(content),
        // 색상 설정
        color: _getAnalyzedColor(content),
        // 구도 설정
        composition: _getAnalyzedComposition(content),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('고급옵션이 자동으로 설정되었습니다 (조명, 분위기, 색상, 구도)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 일기 내용을 분석해서 조명 설정
  LightingOption _getAnalyzedLighting(String content) {
    if (content.contains('밝') || content.contains('환하') || content.contains('햇빛')) {
      return LightingOption.natural;
    } else if (content.contains('어둡') || content.contains('밤') || content.contains('그늘')) {
      return LightingOption.night;
    } else if (content.contains('따뜻') || content.contains('포근') || content.contains('노을')) {
      return LightingOption.warm;
    } else if (content.contains('시원') || content.contains('차가')) {
      return LightingOption.cool;
    } else if (content.contains('석양') || content.contains('황혼')) {
      return LightingOption.sunset;
    }
    return LightingOption.natural;
  }

  // 일기 내용을 분석해서 분위기 설정
  MoodOption _getAnalyzedMood(String content) {
    if (content.contains('평화') || content.contains('고요') || content.contains('차분')) {
      return MoodOption.peaceful;
    } else if (content.contains('행복') || content.contains('기쁘') || content.contains('즐거') || content.contains('설레') || content.contains('신나') || content.contains('활기')) {
      return MoodOption.energetic;
    } else if (content.contains('슬프') || content.contains('우울') || content.contains('힘들')) {
      return MoodOption.melancholic;
    } else if (content.contains('신비') || content.contains('이상')) {
      return MoodOption.mysterious;
    } else if (content.contains('꿈') || content.contains('환상')) {
      return MoodOption.dreamy;
    } else if (content.contains('추억') || content.contains('옛날')) {
      return MoodOption.nostalgic;
    }
    return MoodOption.peaceful;
  }

  // 일기 내용을 분석해서 색상 설정
  ColorOption _getAnalyzedColor(String content) {
    if (content.contains('화려') || content.contains('선명') || content.contains('밝은색')) {
      return ColorOption.vibrant;
    } else if (content.contains('부드러') || content.contains('연한') || content.contains('파스텔')) {
      return ColorOption.pastel;
    } else if (content.contains('흑백') || content.contains('단색')) {
      return ColorOption.monochrome;
    } else if (content.contains('옛날') || content.contains('고전')) {
      return ColorOption.sepia;
    } else if (content.contains('자연') || content.contains('나무') || content.contains('풀') || content.contains('흙')) {
      return ColorOption.earthTone;
    } else if (content.contains('네온') || content.contains('전자') || content.contains('미래')) {
      return ColorOption.neonPop;
    }
    return ColorOption.earthTone;
  }

  // 일기 내용을 분석해서 구도 설정
  CompositionOption _getAnalyzedComposition(String content) {
    if (content.contains('가까이') || content.contains('자세히') || content.contains('얼굴')) {
      return CompositionOption.closeUp;
    } else if (content.contains('풍경') || content.contains('경치') || content.contains('멀리') || content.contains('넓은')) {
      return CompositionOption.wideAngle;
    } else if (content.contains('위에서') || content.contains('내려다')) {
      return CompositionOption.birdEye;
    } else if (content.contains('아래에서') || content.contains('올려다')) {
      return CompositionOption.lowAngle;
    }
    return CompositionOption.closeUp;
  }

  // 프리미엄 기능 안내 다이얼로그
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.orange[400]),
            const SizedBox(width: 8),
            const Text('프리미엄으로 업그레이드'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '프리미엄으로 업그레이드하고 더 특별한 AI 그림일기를 만들어보세요!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // 사진 업로드 혜택
              _buildPremiumFeature(
                Icons.add_photo_alternate,
                '사진 업로드 및 갤러리',
                '여러 장의 사진을 업로드하여 일기와 함께 보관하고, AI 이미지와 함께 갤러리로 감상하세요',
                Colors.teal,
              ),

              const SizedBox(height: 16),

              // 글꼴 혜택
              _buildPremiumFeature(
                Icons.font_download,
                '10가지 프리미엄 글꼴',
                '개구쟁이체, 독도체, 나눔손글씨 펜 등 아름다운 한글 폰트로 더욱 개성있는 일기를 작성하세요',
                Colors.purple,
              ),

              const SizedBox(height: 16),

              // 스타일 혜택
              _buildPremiumFeature(
                Icons.palette,
                '6가지 프리미엄 아트 스타일',
                '수채화, 유화, 파스텔, 디지털 아트 등 다양한 스타일로 매일 다른 느낌의 그림을 생성하세요',
                Colors.pink,
              ),

              const SizedBox(height: 16),

              // 고급 옵션 혜택
              _buildPremiumFeature(
                Icons.tune,
                '고급 이미지 제어 옵션',
                '조명, 분위기, 색상, 구도를 세밀하게 조정하여 원하는 완벽한 그림을 만들어보세요',
                Colors.amber,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '지금 프리미엄으로 업그레이드',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '더 감동적이고 아름다운 AI 그림일기를 경험해보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프리미엄 기능은 곧 출시됩니다!')),
              );
            },
            child: const Text('월 ₩4,900'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 재생성 프리미엄 안내 다이얼로그
  void _showPremiumRegenerationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '프리미엄 전용 기능',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: Colors.orange.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 이미지 재생성',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '프리미엄에서만 제공되는 기능입니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '프리미엄 구독 시 혜택:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              _buildBenefitItem(
                Icons.autorenew,
                '무제한 이미지 재생성',
                '원하는 그림이 나올 때까지 무제한 재생성',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.block,
                '광고 없는 쾌적한 환경',
                '모든 광고 제거로 집중된 일기 작성',
                Colors.red,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.palette,
                '다양한 아트 스타일',
                '6가지 프리미엄 스타일로 매일 다른 느낌',
                Colors.pink,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.tune,
                '고급 이미지 제어',
                '조명, 분위기, 색상, 구도 세밀 조정',
                Colors.purple,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '나중에',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/settings');
            },
            icon: const Icon(Icons.diamond, size: 18),
            label: const Text('프리미엄 알아보기'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 무료 사용자 5개 제한 안내 다이얼로그
  void _showFreeLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '무료 버전 제한',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '일기 5개 작성 완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '무료 버전에서는 최대 5개까지만 작성 가능합니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '프리미엄으로 업그레이드하면:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              _buildBenefitItem(
                Icons.all_inclusive,
                '무제한 일기 작성',
                '원하는 만큼 일기를 작성하고 추억을 기록하세요',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.block,
                '광고 없는 쾌적한 환경',
                '모든 광고 제거로 집중된 일기 작성',
                Colors.red,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.palette,
                '프리미엄 아트 스타일',
                '6가지 추가 스타일로 매일 다른 느낌',
                Colors.pink,
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                Icons.tune,
                '고급 이미지 제어',
                '조명, 분위기, 색상, 구도 등 세밀 조정',
                Colors.purple,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '나중에',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/settings');
            },
            icon: const Icon(Icons.diamond, size: 18),
            label: const Text('프리미엄 알아보기'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 혜택 항목 위젯
  Widget _buildBenefitItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 사진 선택
  Future<void> _pickPhotos() async {
    // 중복 호출 방지
    if (_isPickingImage) return;

    final subscription = ref.read(subscriptionProvider);
    final maxPhotos = subscription.isPremium ? 3 : 1;

    // 이미 최대 개수만큼 선택했는지 확인
    if (_selectedPhotos.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscription.isPremium
            ? '최대 3장까지 선택할 수 있습니다'
            : '무료 버전에서는 1장만 선택할 수 있습니다. 프리미엄으로 업그레이드하여 최대 3장까지 업로드하세요!'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        // 선택 가능한 개수 계산
        final remainingSlots = maxPhotos - _selectedPhotos.length;
        final filesToAdd = pickedFiles.take(remainingSlots).toList();

        if (pickedFiles.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(subscription.isPremium
                ? '최대 ${maxPhotos}장까지만 선택할 수 있습니다. ${remainingSlots}장만 추가되었습니다'
                : '무료 버전에서는 1장만 선택할 수 있습니다'),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // 영구 저장소로 복사
        final List<String> permanentPaths = [];
        for (final pickedFile in filesToAdd) {
          try {
            // 영구 디렉토리 가져오기
            final directory = await getApplicationDocumentsDirectory();
            final imagesDir = Directory(path.join(directory.path, 'user_photos'));

            // 디렉토리가 없으면 생성
            if (!await imagesDir.exists()) {
              await imagesDir.create(recursive: true);
            }

            // 파일명 생성 (타임스탬프 기반)
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final extension = pickedFile.path.split('.').last;
            final fileName = 'user_photo_$timestamp.$extension';
            final permanentPath = path.join(imagesDir.path, fileName);

            // 파일 복사
            final sourceFile = File(pickedFile.path);
            await sourceFile.copy(permanentPath);

            permanentPaths.add(permanentPath);
            print('사용자 사진 영구 저장: $permanentPath');
          } catch (e) {
            print('사진 저장 오류: $e');
          }
        }

        setState(() {
          _selectedPhotos.addAll(permanentPaths);
          // 사진 선택 후 자동으로 ExpansionTile 펼치기
          if (permanentPaths.isNotEmpty) {
            _photoExpansionController.expand();
          }
        });
      }
    } catch (e) {
      print('사진 선택 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 실패: $e')),
        );
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  // 사진 삭제
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  // 프리뷰 이미지 갤러리 (AI 이미지 + 사용자 사진)
  Widget _buildPreviewImageGallery() {
    // AI 이미지와 사용자 사진을 합친 전체 이미지 리스트
    final List<Map<String, dynamic>> allImages = [];

    // AI 생성 이미지 추가
    if (_generatedImageUrl != null) {
      allImages.add({
        'url': _generatedImageUrl!,
        'isAI': true,
      });
    }

    // 사용자 사진 추가
    for (var photoPath in _selectedPhotos) {
      allImages.add({
        'url': photoPath,
        'isAI': false,
      });
    }

    if (allImages.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'AI 이미지가 생성되지 않았습니다',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    if (allImages.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          child: _buildImageWithBadge(allImages[0]['url'], allImages[0]['isAI']),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: _buildImageGallery(allImages),
      ),
    );
  }

  // 배지가 있는 단일 이미지
  Widget _buildImageWithBadge(String imageUrl, bool isAI) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImageWidget(imageUrl),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAI ? Colors.purple.withOpacity(0.9) : Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAI ? Icons.auto_awesome : Icons.photo,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isAI ? 'AI 생성' : '내 사진',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============== Phase 2: 하이브리드 모델 다이얼로그 ==============

  /// 광고 안내 다이얼로그 (첫 번째 또는 일반)
  Future<bool> _showAdExplanationDialog({
    required bool isFirstTime,
    required int dailyCount,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 제목
            Text(
              isFirstTime ? '축하합니다!' : '광고를 보고 계속 사용하세요',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // 설명
            if (isFirstTime) ...[
              const Text(
                '5개의 일기를 작성하셨네요!\n이제 광고를 보고 무료로 계속 사용하세요',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                '오늘 $dailyCount/3개 생성했습니다',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // 혜택 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    icon: Icons.play_circle_outline,
                    text: '30초 광고 시청',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
                  const SizedBox(height: 8),
                  _buildBenefitRow(
                    icon: Icons.auto_stories,
                    text: '일기 1개 생성',
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 일일 할당량
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '매일 3개까지 무료 생성',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '나중에',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('광고 보기'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    ) ?? false;
  }

  /// 일일 제한 다이얼로그
  void _showDailyLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '오늘의 무료 생성 완료!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              '오늘은 이미 3개를 생성하셨습니다.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 리셋 시간 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내일 00:00에',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                      Text(
                        '다시 3개 생성 가능',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '또는 지금 바로 무제한 사용하려면?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),

            const SizedBox(height: 16),

            // 프리미엄 혜택
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.diamond, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '프리미엄 혜택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDailyLimitFeatureItem(Icons.all_inclusive, '무제한 이미지 생성'),
                  _buildDailyLimitFeatureItem(Icons.block, '광고 완전 제거'),
                  _buildDailyLimitFeatureItem(Icons.palette, '프리미엄 스타일 12개'),
                  _buildDailyLimitFeatureItem(Icons.refresh, '무제한 재생성'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '나중에',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/settings'); // 프리미엄 구독 화면으로
            },
            icon: const Icon(Icons.diamond, size: 18),
            label: const Text('프리미엄 알아보기'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  /// 광고 실패 다이얼로그
  void _showAdFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text(
              '광고 시청 실패',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          '광고를 불러올 수 없거나 시청이 중단되었습니다.\n\n'
          '네트워크 연결을 확인하고 다시 시도해주세요.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 광고 시청 완료 애니메이션
  void _showAdCompletionAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '광고 시청 완료!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '일기 생성을 시작합니다...',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              Navigator.pop(context);
              // 일기 생성 시작
            },
          ),
        ),
      ),
    );
  }

  /// 프리미엄 기능 항목 (일일 제한 다이얼로그용)
  Widget _buildDailyLimitFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  /// 혜택 행 (광고 안내 다이얼로그용)
  Widget _buildBenefitRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============== 이미지 갤러리 위젯 ==============

  // 가로 스크롤 갤러리
  Widget _buildImageGallery(List<Map<String, dynamic>> images) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: EdgeInsets.only(
            left: index == 0 ? 0 : 8,
            right: index == images.length - 1 ? 0 : 8,
          ),
          child: _buildImageWithBadge(
            images[index]['url'],
            images[index]['isAI'],
          ),
        );
      },
    );
  }

}