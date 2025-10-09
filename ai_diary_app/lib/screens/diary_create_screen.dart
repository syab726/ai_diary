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


  Future<void> _generateDiary() async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    print('=== _generateDiary 시작 ===');
    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
      _progressMessage = _selectedPhotos.isNotEmpty ? '사진 분석 중...' : '감정 분석 중...';
      print('_isGeneratingImage = true 설정됨');
    });

    try {
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
        _selectedPhotos,
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


  // 선택한 스타일과 옵션으로 이미지 재생성
  Future<void> _regenerateImage(ImageStyle style, AdvancedImageOptions advancedOptions) async {
    if (!_formKey.currentState!.validate()) return;

    final subscription = ref.read(subscriptionProvider);

    setState(() {
      _isLoading = true;
      _isGeneratingImage = true;
      _progressMessage = _selectedPhotos.isNotEmpty ? '사진 분석 중...' : '감정 분석 중...';
    });

    try {
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
        _selectedPhotos,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '내 사진',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final subscription = ref.read(subscriptionProvider);
                                  if (subscription.isPremium) {
                                    _pickPhotos();
                                  } else {
                                    _showPremiumDialog();
                                  }
                                },
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
                            ],
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

  // 사진 선택
  Future<void> _pickPhotos() async {
    // 중복 호출 방지
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        // 영구 저장소로 복사
        final List<String> permanentPaths = [];
        for (final pickedFile in pickedFiles) {
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