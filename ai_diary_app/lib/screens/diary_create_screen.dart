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
  String? _generatedImageUrl;
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


  Future<void> _generateDiary() async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    print('=== _generateDiary 시작 ===');
    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
      print('_isGeneratingImage = true 설정됨');
    });

    try {
      final selectedStyle = ref.read(defaultImageStyleProvider);

      AdvancedImageOptions effectiveAdvancedOptions = _advancedOptions;
      ImageTime effectiveTime = _selectedTime;
      ImageWeather effectiveWeather = _selectedWeather;


      // AI 서비스를 통한 이미지 생성
      final Map<String, dynamic> result = await AIService.processEntry(
        _contentController.text.trim(),
        selectedStyle.displayName,
        subscription.isPremium ? effectiveAdvancedOptions : null,
        _perspectiveOptions,
        subscription.isPremium ? effectiveTime : null,
        subscription.isPremium ? effectiveWeather : null,
      );

      final imageUrl = result['imageUrl'] as String?;
      final emotion = result['emotion'] as String?;
      final keywords = List<String>.from(result['keywords'] as List? ?? []);
      final aiPrompt = result['imagePrompt'] as String?;

      final diary = DiaryEntry(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        generatedImageUrl: imageUrl,
        emotion: emotion,
        keywords: keywords,
        aiPrompt: aiPrompt,
        imageStyle: selectedStyle,
        fontFamily: _selectedFont,
        imageTime: _selectedTime,
        imageWeather: _selectedWeather,
        imageSeason: _selectedSeason,
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

    setState(() {
      _isLoading = true;
    });

    try {
      String diaryId;
      if (_existingEntry != null) {
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


  // 선택한 스타일과 옵션으로 이미지 재생성
  Future<void> _regenerateImage(ImageStyle style, AdvancedImageOptions advancedOptions) async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
    });

    try {
      // AI 서비스를 통한 이미지 재생성
      final Map<String, dynamic> result = await AIService.processEntry(
        _contentController.text.trim(),
        style.displayName,
        subscription.isPremium ? advancedOptions : null,
        _perspectiveOptions,
        subscription.isPremium ? _selectedTime : null,
        subscription.isPremium ? _selectedWeather : null,
      );

      final newImageUrl = result['imageUrl'] as String?;
      final emotion = result['emotion'] as String?;
      final keywords = List<String>.from(result['keywords'] as List? ?? []);
      final aiPrompt = result['imagePrompt'] as String?;

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
          emotion: emotion,
          keywords: keywords,
          aiPrompt: aiPrompt,
          imageStyle: style,
          fontFamily: _selectedFont,
          hasBeenRegenerated: true,
          imageTime: _selectedTime,
          imageWeather: _selectedWeather,
          imageSeason: _selectedSeason,
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
          onPressed: () => context.go('/list'),
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '이미지 생성중입니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
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

                          // 생성된 이미지 표시
                          if (_generatedImageUrl != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              '생성된 이미지',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImageWidget(_generatedImageUrl!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),


                  // 탭 옵션 영역 (조건부 표시)
                  !_isEditMode || subscription.isPremium
                      ? Container(
                          height: 400,
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

}