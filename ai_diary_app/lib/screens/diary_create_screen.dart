import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/diary_entry.dart';
import '../models/image_style.dart';
import '../models/image_options.dart';
import '../models/image_ratio.dart';
import '../models/perspective_options.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../providers/diary_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/image_style_provider.dart';
import '../widgets/image_viewer.dart';
import '../widgets/tabbed_option_selector.dart';
import '../l10n/app_localizations.dart';
import '../providers/font_provider.dart';
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
  bool _showAdvancedOptions = false;
  AdvancedImageOptions _advancedOptions = const AdvancedImageOptions();
  ImageRatio _selectedRatio = ImageRatio.wide;
  PerspectiveOptions _perspectiveOptions = const PerspectiveOptions();
  String? _selectedThemePresetId;
  FontFamily _selectedFont = FontFamily.notoSans;


  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
    // 수정 모드에서는 처음부터 고급 옵션을 표시
    if (widget.existingDiaryId != null) {
      _showAdvancedOptions = true;
    }
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
        final entry = await DatabaseService.getDiaryById(widget.existingDiaryId!);
        if (entry != null) {
          setState(() {
            _existingEntry = entry;
            _titleController.text = entry.title;
            _contentController.text = entry.content;
            _generatedImageUrl = entry.generatedImageUrl;
            _selectedFont = entry.fontFamily ?? FontFamily.notoSans;
          });
        }
      } catch (e) {
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

      // AI 서비스를 통한 이미지 생성
      final Map<String, dynamic> result = await AIService.processEntry(
        _contentController.text.trim(),
        selectedStyle.displayName,
        subscription.isPremium ? _advancedOptions : null,
        _perspectiveOptions,
        subscription.isPremium ? _selectedRatio : null,
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
      );

      String diaryId;
      if (_existingEntry != null) {
        final updatedDiary = diary.copyWith(
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
    bool isSuccess = false;

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
        subscription.isPremium ? _selectedRatio : null,
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
        );

        await DatabaseService.updateDiary(updatedDiary);
        isSuccess = true;

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

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리미엄 기능'),
        content: const Text('이 기능을 사용하려면 프리미엄 구독이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/settings');
            },
            child: const Text('구독하기'),
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
          : SingleChildScrollView(
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
                            maxLines: 6,
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

                  // 탭 옵션 영역
                  Container(
                    height: 400, // 고정 높이로 설정
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TabbedOptionSelector(
                      isPremium: subscription.isPremium,
                      advancedOptions: _advancedOptions,
                      onAdvancedOptionsChanged: (options) {
                        setState(() {
                          _advancedOptions = options;
                        });
                      },
                      selectedRatio: _selectedRatio,
                      onRatioChanged: (ratio) {
                        setState(() {
                          _selectedRatio = ratio;
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
                      selectedFont: _selectedFont,
                      onFontChanged: (font) {
                        setState(() {
                          _selectedFont = font;
                        });
                      },
                    ),
                  ),

                  // 수정 모드 안내 메시지 (버튼 바로 위)
                  if (_isEditMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '그림은 일기당 1회만 수정 가능합니다',
                              style: TextStyle(
                                color: Color(0xFFD69E2E),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 버튼 영역
                  Container(
                  padding: const EdgeInsets.all(16.0),
                  child: _isEditMode
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/detail/${_existingEntry!.id}'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Color(0xFF38B2AC)),
                                foregroundColor: const Color(0xFF38B2AC),
                              ),
                              child: const Text('일기만 수정'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isGeneratingImage
                                  ? null
                                  : () {
                                      final selectedStyle = ref.read(defaultImageStyleProvider);
                                      _regenerateImage(selectedStyle, _advancedOptions);
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  : const Text('그림+일기 수정'),
                            ),
                          ),
                        ],
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
              ),
    );
  }
}