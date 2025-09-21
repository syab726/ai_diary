import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diariesAsync = ref.watch(diaryEntriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'AI 그림일기',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(diaryEntriesProvider.notifier).loadDiaries(),
              ),
            ],
          ),
          if (searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Chip(
                  label: Text('검색: $searchQuery'),
                  onDeleted: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(diaryEntriesProvider.notifier).loadDiaries();
                  },
                ),
              ),
            ),
          diariesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      '오류가 발생했습니다',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.read(diaryEntriesProvider.notifier).loadDiaries(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
            data: (diaries) {
              if (diaries.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          '아직 작성한 일기가 없습니다',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI가 그림을 그려주는 특별한 일기를 시작해보세요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/create'),
                          icon: const Icon(Icons.add),
                          label: const Text('첫 일기 작성하기'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final diary = diaries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DiaryCard(
                          diary: diary,
                          onTap: () => context.go('/detail/${diary.id}'),
                        ),
                      );
                    },
                    childCount: diaries.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create'),
        label: const Text('일기 쓰기'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 검색'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '검색할 내용을 입력하세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => _performSearch(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => _performSearch(context, _searchController.text),
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(diaryEntriesProvider.notifier).searchDiaries(query);
    _searchController.clear();
    Navigator.pop(context);
  }
}
