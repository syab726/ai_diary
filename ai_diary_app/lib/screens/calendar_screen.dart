import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _highlightedDiaryId;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    // URL 파라미터에서 선택된 날짜와 일기 ID 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouter.of(context).routeInformationProvider.value.uri;
      final selectedDateString = uri.queryParameters['selectedDate'];
      final selectedDiaryId = uri.queryParameters['selectedDiary'];

      if (kDebugMode) print('Calendar 초기화: URL 체크 중...');
      if (selectedDateString != null && selectedDiaryId != null) {
        try {
          if (kDebugMode) print('Calendar: URL 파라미터 감지됨! - 날짜: $selectedDateString, 일기ID: $selectedDiaryId');
          final selectedDate = DateTime.parse(selectedDateString);
          setState(() {
            _focusedDay = selectedDate;
            _selectedDay = selectedDate;
            _highlightedDiaryId = selectedDiaryId;
          });
          if (kDebugMode) print('Calendar: 상태 업데이트 완료! - 포커스된 날짜: $selectedDate, 강조할 일기: $selectedDiaryId');

          // 3초 후 하이라이트 제거
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _highlightedDiaryId = null;
              });
            }
          });
        } catch (e) {
          if (kDebugMode) print('날짜 파싱 오류: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final diariesAsync = ref.watch(diaryEntriesProvider);

    // 일기 데이터가 로드되었을 때 URL 파라미터 처리
    diariesAsync.whenData((diaries) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final uri = GoRouter.of(context).routeInformationProvider.value.uri;
        final selectedDateString = uri.queryParameters['selectedDate'];
        final selectedDiaryId = uri.queryParameters['selectedDiary'];

        if (selectedDateString != null && selectedDiaryId != null && _highlightedDiaryId != selectedDiaryId) {
          try {
            if (kDebugMode) print('Calendar: 일기 데이터 로드 완료 후 URL 파라미터 처리 - 날짜: $selectedDateString, 일기ID: $selectedDiaryId');
            final selectedDate = DateTime.parse(selectedDateString);

            // 해당 일기가 실제로 존재하는지 확인
            final targetDiary = diaries.firstWhere(
              (diary) => diary.id == selectedDiaryId,
              orElse: () => throw Exception('일기를 찾을 수 없습니다'),
            );

            setState(() {
              _focusedDay = selectedDate;
              _selectedDay = selectedDate;
              _highlightedDiaryId = selectedDiaryId;
            });

            if (kDebugMode) print('Calendar: 타겟 일기 확인 완료! - 제목: ${targetDiary.title}');
            if (kDebugMode) print('Calendar: 하이라이트 설정 완료! - 일기ID: $selectedDiaryId');

            // 3초 후 하이라이트 제거
            Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _highlightedDiaryId = null;
                });
                if (kDebugMode) print('Calendar: 하이라이트 제거됨');
              }
            });
          } catch (e) {
            if (kDebugMode) print('Calendar: 일기 처리 오류 - $e');
          }
        }
      });
      return diaries;
    });
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 상단 앱바
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(_focusedDay),
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4A5568)),
                onPressed: () => Navigator.of(context).canPop() 
                    ? Navigator.of(context).pop()
                    : context.go('/list'),
              ),
            ),
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
                  icon: const Icon(Icons.today, color: Color(0xFF4A5568)),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime.now();
                      _selectedDay = DateTime.now();
                    });
                  },
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
                  icon: const Icon(Icons.view_list, color: Color(0xFF4A5568)),
                  onPressed: () => context.go('/list'),
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
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
          ),
          
          // 달력
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: diariesAsync.when(
                loading: () => const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 400,
                  child: Center(child: Text(AppLocalizations.of(context).calendarLoadError ?? '달력을 불러올 수 없습니다')),
                ),
                data: (diaries) => Container(
                  height: 400, // 고정 높이 설정
                  child: TableCalendar<DiaryEntry>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  eventLoader: (day) => _getEventsForDay(diaries, day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Color(0xFF4A5568)),
                    holidayTextStyle: TextStyle(color: Color(0xFF4A5568)),
                    defaultTextStyle: TextStyle(color: Color(0xFF2D3748)),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    todayTextStyle: TextStyle(color: Colors.white),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF667EEA),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF764BA2),
                      shape: BoxShape.circle,
                    ),
                    // 마커 비활성화 - 커스텀 빌더 사용
                    markersMaxCount: 0,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) =>
                        _buildDayCell(context, day, diaries, false, false),
                    selectedBuilder: (context, day, focusedDay) =>
                        _buildDayCell(context, day, diaries, true, false),
                    todayBuilder: (context, day, focusedDay) =>
                        _buildDayCell(context, day, diaries, false, true),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF4A5568)),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
                    titleTextStyle: TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                ),
              ),
            ),
          ),
          
          // 선택된 날짜의 일기들
          if (_selectedDay != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  DateFormat('M월 d일 EEEE', 'ko').format(_selectedDay!),
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            diariesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SliverToBoxAdapter(
                child: Center(child: Text('일기를 불러올 수 없습니다')),
              ),
              data: (diaries) {
                final selectedDayDiaries = _getEventsForDay(diaries, _selectedDay!);
                
                if (selectedDayDiaries.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.edit_calendar_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '이 날에는 작성한 일기가 없습니다',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/create'),
                            icon: const Icon(Icons.add),
                            label: const Text('일기 작성하기'),
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
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final diary = selectedDayDiaries[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildDiaryCard(diary),
                        );
                      },
                      childCount: selectedDayDiaries.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<DiaryEntry> _getEventsForDay(List<DiaryEntry> diaries, DateTime day) {
    return diaries.where((diary) {
      return isSameDay(diary.createdAt, day);
    }).toList();
  }

  Widget _buildDayCell(BuildContext context, DateTime day, List<DiaryEntry> allDiaries, 
                       bool isSelected, bool isToday) {
    final dayDiaries = _getEventsForDay(allDiaries, day);
    final hasEntry = dayDiaries.isNotEmpty;
    
    Color? backgroundColor;
    Color? textColor;
    
    if (isSelected) {
      backgroundColor = const Color(0xFF667EEA);
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = const Color(0xFF764BA2);
      textColor = Colors.white;
    } else if (hasEntry) {
      // 가장 최근 일기의 감정 색상 사용
      final latestDiary = dayDiaries.reduce((a, b) => 
          a.createdAt.isAfter(b.createdAt) ? a : b);
      backgroundColor = _getEmotionColor(latestDiary.emotion ?? 'peaceful')
          .withOpacity(0.15);
      textColor = const Color(0xFF2D3748);
    } else {
      textColor = const Color(0xFF2D3748);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: hasEntry && !isSelected && !isToday
            ? Border.all(
                color: _getEmotionColor(dayDiaries.first.emotion ?? 'peaceful'),
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: hasEntry ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry diary) {
    final isHighlighted = _highlightedDiaryId == diary.id;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: isHighlighted ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final dateString = '${diary.createdAt.year}-${diary.createdAt.month.toString().padLeft(2, '0')}-${diary.createdAt.day.toString().padLeft(2, '0')}';
          if (kDebugMode) print('Calendar: 일기 카드 클릭 - 일기ID: ${diary.id}, 날짜: $dateString');
          if (kDebugMode) print('Calendar: 이동할 URL - /detail/${diary.id}?from=calendar&date=$dateString&diaryId=${diary.id}');
          context.go('/detail/${diary.id}?from=calendar&date=$dateString&diaryId=${diary.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            if (diary.generatedImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildImageWidget(diary.generatedImageUrl!),
                ),
              ),
            
            // 내용
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 시간
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          diary.title,
                          style: const TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(diary.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 내용 미리보기
                  Text(
                    diary.content,
                    style: const TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 감정과 키워드
                  if (diary.emotion != null || diary.keywords.isNotEmpty)
                    Row(
                      children: [
                        // 감정
                        if (diary.emotion != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getEmotionColor(diary.emotion!)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getEmotionEmoji(diary.emotion!),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getEmotionText(diary.emotion!, context),
                                  style: TextStyle(
                                    color: _getEmotionColor(diary.emotion!),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // 키워드 개수
                        if (diary.keywords.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${diary.keywords.length}${AppLocalizations.of(context).tagsCount}',
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFD93D);
      case 'sad':
        return const Color(0xFF6366F1);
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

  String _getEmotionText(String emotion, BuildContext context) {
    return AppLocalizations.of(context).getEmotionText(emotion);
  }

  Widget _buildImageWidget(String imageUrl) {
    // 레거시 외부 이미지 URL (Unsplash, Picsum) 무시 (외부 서비스 의존성 제거)
    if (imageUrl.contains('unsplash.com') || imageUrl.contains('picsum.photos')) {
      if (kDebugMode) print('레거시 외부 이미지 URL 무시: $imageUrl');
      return const SizedBox.shrink(); // 이미지 영역을 표시하지 않음
    }

    // file:// 경로인 경우 로컬 파일로 처리
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      } else {
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
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        return _buildImagePlaceholder();
      }
    }
    // HTTP URL인 경우 네트워크 이미지로 처리
    else if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          return _buildImagePlaceholder();
        },
      );
    }
    // 알 수 없는 형식
    else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}