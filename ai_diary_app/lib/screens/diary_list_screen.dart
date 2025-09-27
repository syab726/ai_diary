import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../l10n/app_localizations.dart';

class DiaryListScreen extends ConsumerStatefulWidget {
  const DiaryListScreen({super.key});

  @override
  ConsumerState<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DiaryListScreen: build() 호출됨');
    final diariesAsync = ref.watch(diaryEntriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    print('DiaryListScreen: diariesAsync 상태: ${diariesAsync.runtimeType}');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 상단 앱바
          SliverAppBar(
            expandedHeight: 56,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context).appTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            titleSpacing: 16,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF4A5568)),
                  onPressed: () => _showSearchDialog(context),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Color(0xFF4A5568)),
                  onPressed: () => context.go('/calendar'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF4A5568)),
                  onPressed: () => context.go('/settings'),
                ),
              ),
            ],
          ),
          
          // 검색 칩
          if (searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Chip(
                  label: Text('${AppLocalizations.of(context).searchLabel}: $searchQuery'),
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                  deleteIconColor: const Color(0xFF667EEA),
                  onDeleted: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(diaryEntriesProvider.notifier).loadDiaries();
                  },
                ),
              ),
            ),
          
          // 일기 목록
          diariesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '오류가 발생했습니다',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(diaryEntriesProvider.notifier).loadDiaries(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
            data: (diaries) {
              print('DiaryListScreen: 가져온 일기 개수: ${diaries.length}');
              for (int i = 0; i < diaries.length; i++) {
                print('일기 $i: 제목=${diaries[i].title}, 내용길이=${diaries[i].content.length}, 내용="${diaries[i].content}"');
              }
              if (diaries.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).noEntries,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).startWithAiDiary,
                          style: const TextStyle(
                            color: Color(0xFF718096),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/create'),
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context).createFirstEntry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 월별로 그룹화
              final groupedDiaries = <String, List<DiaryEntry>>{};
              for (final diary in diaries) {
                final locale = Localizations.localeOf(context);
                final dateFormat = locale.languageCode == 'ko' ? 'yyyy년 M월' :
                                  locale.languageCode == 'ja' ? 'yyyy年M月' :
                                  locale.languageCode == 'zh' ? 'yyyy年M月' :
                                  'MMMM yyyy';
                final monthKey = DateFormat(dateFormat, locale.languageCode).format(diary.createdAt);
                groupedDiaries[monthKey] ??= [];
                groupedDiaries[monthKey]!.add(diary);
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monthKeys = groupedDiaries.keys.toList()..sort((a, b) => b.compareTo(a));
                    final monthKey = monthKeys[index];
                    final monthDiaries = groupedDiaries[monthKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 월 헤더
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Text(
                            monthKey,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                              fontSize: 20,
                            ),
                          ),
                        ),
                        
                        // 해당 월의 일기들
                        ...monthDiaries.map((diary) => Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDiaryCard(diary),
                        )).toList(),
                      ],
                    );
                  },
                  childCount: groupedDiaries.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry diary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go('/detail/${diary.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            if (diary.imageData != null || diary.generatedImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: diary.imageData != null
                      ? Image.memory(
                          diary.imageData!,
                          fit: BoxFit.cover,
                        )
                      : (diary.generatedImageUrl != null
                          ? _buildImageWidget(diary.generatedImageUrl!)
                          : _buildImagePlaceholder()),
                ),
              ),
            
            // 제목만 표시
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                diary.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // file:// 경로인 경우 로컬 파일로 처리
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      // 파일이 존재하는지 확인
      if (file.existsSync()) {
        return Image.file(
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
        return Image.memory(
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
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF9FAFB),
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
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Color(0xFFD1D5DB),
          ),
          SizedBox(height: 12),
          Text(
            'AI가 그린 이미지',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).diarySearch,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF667EEA)),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                ),
                autofocus: true,
                onSubmitted: (value) => _performSearch(context, value),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _performSearch(context, _searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('검색'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(diaryEntriesProvider.notifier).searchDiaries(query);
    _searchController.clear();
    Navigator.pop(context);
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFB800);
      case 'sad':
        return const Color(0xFF3B82F6);
      case 'angry':
        return const Color(0xFFEF4444);
      case 'excited':
        return const Color(0xFFFF6B35);
      case 'peaceful':
        return const Color(0xFF10B981);
      case 'anxious':
        return const Color(0xFF8B5CF6);
      case 'grateful':
        return const Color(0xFFEC4899);
      case 'nostalgic':
        return const Color(0xFF92400E);
      case 'romantic':
        return const Color(0xFFF472B6);
      case 'frustrated':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'excited':
        return '🎉';
      case 'peaceful':
        return '😌';
      case 'anxious':
        return '😰';
      case 'grateful':
        return '🙏';
      case 'nostalgic':
        return '🥺';
      case 'romantic':
        return '💕';
      case 'frustrated':
        return '😤';
      default:
        return '😐';
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
}