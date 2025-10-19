import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../providers/diary_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/image_viewer.dart';
import '../models/font_family.dart';
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final String entryId;

  const DiaryDetailScreen({super.key, required this.entryId});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  DiaryEntry? _diary;
  bool _isLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDiary() async {
    try {
      final diary = await DatabaseService.getDiaryById(widget.entryId);
      setState(() {
        _diary = diary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_diary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('일기 상세')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('일기를 찾을 수 없습니다'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 상단 앱바와 이미지
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    print('Detail: Navigator에서 뒤로가기');
                    Navigator.of(context).pop();
                  } else {
                    // URL 쿼리 파라미터 확인
                    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
                    final from = uri.queryParameters['from'];
                    final date = uri.queryParameters['date'];
                    final diaryId = uri.queryParameters['diaryId'];

                    if (kDebugMode) print('Detail: URL 파라미터 - from: $from, date: $date, diaryId: $diaryId');

                    if (from == 'calendar' && date != null && diaryId != null) {
                      print('Detail: 달력으로 이동 - /calendar?selectedDate=$date&selectedDiary=$diaryId');
                      context.go('/calendar?selectedDate=$date&selectedDiary=$diaryId');
                    } else if (from == 'calendar') {
                      print('Detail: 달력으로 이동 (파라미터 없음)');
                      context.go('/calendar');
                    } else {
                      if (kDebugMode) print('Detail: 리스트로 이동');
                      context.go('/list');
                    }
                  }
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageSection(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => context.push('/edit/${widget.entryId}'),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareDiary(ref),
                    ),
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _showDeleteDialog,
                ),
              ),
            ],
          ),

          // 일기 내용
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 날짜
                  Text(
                    _diary!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(_diary!.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 감정과 키워드
                  if (_diary!.emotion != null || _diary!.keywords.isNotEmpty) ...[
                    Row(
                      children: [
                        // 감정
                        if (_diary!.emotion != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getEmotionColor(_diary!.emotion!).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEmotionIcon(_diary!.emotion!),
                                  size: 16,
                                  color: _getEmotionColor(_diary!.emotion!),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getEmotionText(_diary!.emotion!),
                                  style: TextStyle(
                                    color: _getEmotionColor(_diary!.emotion!),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 키워드
                    if (_diary!.keywords.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _diary!.keywords
                            .map((keyword) => Chip(
                                  label: Text(keyword),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                  
                  // 일기 내용
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _diary!.content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  
                  // 수정된 날짜 (있는 경우)
                  if (_diary!.updatedAt != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '마지막 수정: ${DateFormat('yyyy.MM.dd HH:mm').format(_diary!.updatedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
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
            if (kDebugMode) print('로컬 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } else {
        if (kDebugMode) print('로컬 이미지 파일이 존재하지 않음: $filePath');
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
            if (kDebugMode) print('로컬 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } else {
        if (kDebugMode) print('로컬 이미지 파일이 존재하지 않음: $imageUrl');
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
            if (kDebugMode) print('base64 이미지 로드 오류: $error');
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        if (kDebugMode) print('base64 디코딩 오류: $e');
        return _buildImagePlaceholder();
      }
    }
    // HTTP URL인 경우 네트워크 이미지로 처리
    else if (imageUrl.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          if (kDebugMode) print('네트워크 이미지 로드 오류: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    // 알 수 없는 형식
    else {
      if (kDebugMode) print('알 수 없는 이미지 URL 형식: $imageUrl');
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
              title: _diary?.title,
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'AI가 그린 이미지가 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _shareDiary(WidgetRef ref) async {
    final subscription = ref.read(subscriptionProvider);

    String shareText = '${_diary!.title}\n\n${_diary!.content}';
    if (_diary!.emotion != null) {
      shareText += '\n\n오늘의 감정: ${_getEmotionText(_diary!.emotion!)}';
    }
    shareText += '\n\n작성일: ${DateFormat('yyyy.MM.dd').format(_diary!.createdAt)}';
    shareText += '\n\n#AI그림일기 #감정일기';

    // 유료 사용자이고 이미지가 있는 경우 이미지와 함께 공유
    if (subscription.isPremium && _diary!.generatedImageUrl != null) {
      try {
        final imageFile = await _prepareImageForSharing(_diary!.generatedImageUrl!);
        if (imageFile != null) {
          await Share.shareXFiles(
            [imageFile],
            text: shareText,
            subject: _diary!.title
          );
          return;
        }
      } catch (e) {
        if (kDebugMode) print('이미지 공유 중 오류 발생: $e');
        // 이미지 공유 실패 시 텍스트만 공유
      }
    }

    // 무료 사용자이거나 이미지 공유에 실패한 경우 텍스트만 공유
    await Share.share(shareText, subject: _diary!.title);
  }

  Future<XFile?> _prepareImageForSharing(String imageUrl) async {
    try {
      Uint8List? imageBytes;

      // 이미지 데이터 가져오기
      if (imageUrl.startsWith('file://')) {
        final filePath = imageUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (file.existsSync()) {
          imageBytes = await file.readAsBytes();
        }
      } else if (imageUrl.startsWith('data:image/')) {
        final base64Data = imageUrl.split(',')[1];
        imageBytes = base64Decode(base64Data);
      } else if (imageUrl.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(imageUrl));
        final httpResponse = await response.close();
        final bytes = <int>[];
        await for (var chunk in httpResponse) {
          bytes.addAll(chunk);
        }
        imageBytes = Uint8List.fromList(bytes);
      }

      if (imageBytes == null) return null;

      // 임시 파일 생성
      final tempDir = await getTemporaryDirectory();
      final fileName = 'diary_${_diary!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');

      await tempFile.writeAsBytes(imageBytes);

      return XFile(tempFile.path);

    } catch (e) {
      if (kDebugMode) print('이미지 준비 중 오류 발생: $e');
      return null;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('정말로 이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(diaryEntriesProvider.notifier).deleteDiary(widget.entryId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('일기가 삭제되었습니다')),
                );
                context.go('/');
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제 중 오류가 발생했습니다')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.yellow[700]!;
      case 'sad':
        return Colors.blue[700]!;
      case 'angry':
        return Colors.red[700]!;
      case 'excited':
        return Colors.orange[700]!;
      case 'peaceful':
        return Colors.green[700]!;
      case 'anxious':
        return Colors.purple[700]!;
      case 'grateful':
        return Colors.pink[700]!;
      case 'nostalgic':
        return Colors.brown[700]!;
      case 'romantic':
        return Colors.pink[400]!;
      case 'frustrated':
        return Colors.red[900]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'excited':
        return Icons.celebration;
      case 'peaceful':
        return Icons.self_improvement;
      case 'anxious':
        return Icons.psychology_alt;
      case 'grateful':
        return Icons.favorite;
      case 'nostalgic':
        return Icons.history;
      case 'romantic':
        return Icons.favorite_border;
      case 'frustrated':
        return Icons.mood_bad;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getEmotionText(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '행복';
      case 'sad':
        return '슬픔';
      case 'angry':
        return '화남';
      case 'excited':
        return '흥분';
      case 'peaceful':
        return '평온';
      case 'anxious':
        return '불안';
      case 'grateful':
        return '감사';
      case 'nostalgic':
        return '그리움';
      case 'romantic':
        return '로맨틱';
      case 'frustrated':
        return '짜증';
      default:
        return '보통';
    }
  }

  TextStyle _getDiaryTextStyle(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);

    // 기본 텍스트 스타일 설정
    TextStyle baseStyle = TextStyle(
      fontSize: fontSize,
      height: 1.6,
      color: Colors.black87,
    );

    // 일기에 저장된 글꼴이 있으면 해당 글꼴을 사용
    if (_diary != null && _diary!.fontFamily != FontFamily.notoSans) {
      final fontFamily = _diary!.fontFamily;
      try {
        return GoogleFonts.getFont(
          fontFamily.name,
          textStyle: baseStyle,
        );
      } catch (e) {
        if (kDebugMode) print('폰트 로드 실패: ${fontFamily.name}, 기본 폰트 사용');
        return baseStyle;
      }
    }

    return baseStyle;
  }

  // 이미지 섹션 (AI 이미지 + 사용자 사진 갤러리)
  Widget _buildImageSection() {
    if (_diary == null) return _buildImagePlaceholder();

    if (kDebugMode) print('=== _buildImageSection 호출 ===');
    if (kDebugMode) print('AI 이미지 URL: ${_diary!.generatedImageUrl}');
    if (kDebugMode) print('사용자 사진 개수: ${_diary!.userPhotos.length}');
    if (kDebugMode) print('사용자 사진 경로들: ${_diary!.userPhotos}');

    // AI 이미지와 사용자 사진을 합친 전체 이미지 리스트
    final List<Map<String, dynamic>> allImages = [];

    // AI 생성 이미지 추가
    if (_diary!.generatedImageUrl != null) {
      allImages.add({
        'url': _diary!.generatedImageUrl!,
        'isAI': true,
      });
      if (kDebugMode) print('AI 이미지 추가됨');
    }

    // 사용자 사진 추가
    for (var photoPath in _diary!.userPhotos) {
      allImages.add({
        'url': photoPath,
        'isAI': false,
      });
      if (kDebugMode) print('사용자 사진 추가됨: $photoPath');
    }

    if (kDebugMode) print('전체 이미지 개수: ${allImages.length}');

    if (allImages.isEmpty) {
      return _buildImagePlaceholder();
    }

    if (allImages.length == 1) {
      return _buildImageWithBadge(allImages[0]['url'], allImages[0]['isAI']);
    }

    return _buildImageGallery(allImages);
  }

  // 배지가 있는 단일 이미지
  Widget _buildImageWithBadge(String imageUrl, bool isAI) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImageWidget(imageUrl),
        Positioned(
          bottom: 16,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAI ? Colors.purple.withOpacity(0.95) : Colors.blue.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAI ? Icons.auto_awesome : Icons.photo,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  isAI ? 'AI 생성' : '내 사진',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  // 가로 스크롤 갤러리 (PageView + 화살표 + 페이지 인디케이터)
  Widget _buildImageGallery(List<Map<String, dynamic>> images) {
    return Stack(
      children: [
        // 메인 이미지 페이지뷰
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildImageWithBadge(
              images[index]['url'],
              images[index]['isAI'],
            );
          },
        ),

        // 왼쪽 화살표
        if (_currentPage > 0)
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

        // 오른쪽 화살표
        if (_currentPage < images.length - 1)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

        // 페이지 인디케이터 (이미지가 2개 이상일 때만 표시)
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12.0 : 10.0,
                  height: _currentPage == index ? 12.0 : 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
