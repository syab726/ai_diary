import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../models/emotion_insight.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class EmotionStatsScreen extends ConsumerStatefulWidget {
  const EmotionStatsScreen({super.key});

  @override
  ConsumerState<EmotionStatsScreen> createState() => _EmotionStatsScreenState();
}

class _EmotionStatsScreenState extends ConsumerState<EmotionStatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedWeek = 0; // 현재 주를 기준으로 0, -1, -2 (이전 주들)
  int _selectedMonth = 0; // 현재 월을 기준으로 0, -1, -2 (이전 월들)
  int _selectedYear = 0; // 현재 년을 기준으로 0, -1, -2 (이전 년들)

  // 각 타입별 인사이트 상태
  Map<String, String?> _insights = {};
  Map<String, bool> _isGenerating = {};
  Map<String, DateTime?> _lastGenerated = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAndCheckInsights();
  }

  Future<void> _loadAndCheckInsights() async {
    // 각 기간별로 인사이트 로드 및 자동 생성 확인
    await _checkAndGenerateWeeklyInsight();
    await _checkAndGenerateMonthlyInsight();
    await _checkAndGenerateYearlyInsight();
  }

  // 현재 주차 기간 반환
  Map<String, DateTime> _getCurrentWeekPeriod() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return {'start': startOfWeek, 'end': endOfWeek};
  }

  // 현재 월 기간 반환
  Map<String, DateTime> _getCurrentMonthPeriod() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return {'start': startOfMonth, 'end': endOfMonth};
  }

  // 현재 년 기간 반환
  Map<String, DateTime> _getCurrentYearPeriod() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    return {'start': startOfYear, 'end': endOfYear};
  }

  // 주간 인사이트 자동 생성 확인
  Future<void> _checkAndGenerateWeeklyInsight() async {
    final weekPeriod = _getCurrentWeekPeriod();
    final insight = await DatabaseService.getInsightByType('weekly');

    // 이번 주 인사이트가 없거나, 있는 인사이트가 이전 주 것이라면 새로 생성
    bool shouldGenerate = insight == null ||
                         insight.periodEnd.isBefore(weekPeriod['start']!);

    if (shouldGenerate) {
      await _generateInsightForPeriod('weekly', weekPeriod['start']!, weekPeriod['end']!);
    } else if (mounted) {
      setState(() {
        _insights['weekly'] = insight.insightText;
        _lastGenerated['weekly'] = insight.createdAt;
      });
    }
  }

  // 월간 인사이트 자동 생성 확인
  Future<void> _checkAndGenerateMonthlyInsight() async {
    final monthPeriod = _getCurrentMonthPeriod();
    final insight = await DatabaseService.getInsightByType('monthly');

    // 이번 달 인사이트가 없거나, 있는 인사이트가 이전 달 것이라면 새로 생성
    bool shouldGenerate = insight == null ||
                         insight.periodEnd.isBefore(monthPeriod['start']!);

    if (shouldGenerate) {
      await _generateInsightForPeriod('monthly', monthPeriod['start']!, monthPeriod['end']!);
    } else if (mounted) {
      setState(() {
        _insights['monthly'] = insight.insightText;
        _lastGenerated['monthly'] = insight.createdAt;
      });
    }
  }

  // 연간 인사이트 자동 생성 확인
  Future<void> _checkAndGenerateYearlyInsight() async {
    final yearPeriod = _getCurrentYearPeriod();
    final insight = await DatabaseService.getInsightByType('yearly');

    // 올해 인사이트가 없거나, 있는 인사이트가 작년 것이라면 새로 생성
    bool shouldGenerate = insight == null ||
                         insight.periodEnd.isBefore(yearPeriod['start']!);

    if (shouldGenerate) {
      await _generateInsightForPeriod('yearly', yearPeriod['start']!, yearPeriod['end']!);
    } else if (mounted) {
      setState(() {
        _insights['yearly'] = insight.insightText;
        _lastGenerated['yearly'] = insight.createdAt;
      });
    }
  }

  // 특정 기간의 인사이트 생성
  Future<void> _generateInsightForPeriod(String type, DateTime startDate, DateTime endDate) async {
    if (_isGenerating[type] == true) return;

    setState(() {
      _isGenerating[type] = true;
    });

    try {
      // 해당 기간의 일기 가져오기
      final diariesAsync = ref.read(diaryEntriesProvider);
      final allDiaries = diariesAsync.value ?? [];

      final periodDiaries = allDiaries.where((diary) {
        return diary.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
               diary.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      if (periodDiaries.isEmpty) {
        setState(() {
          _isGenerating[type] = false;
        });
        return;
      }

      // 일기 데이터를 AI 서비스 형식으로 변환
      final diaryData = periodDiaries.map((entry) {
        return {
          'date': DateFormat('yyyy-MM-dd').format(entry.createdAt),
          'emotion': entry.emotion ?? '없음',
          'keywords': entry.keywords ?? [],
        };
      }).toList();

      // AI 인사이트 생성
      final insightText = await AIService.generateEmotionInsight(diaryData, type);

      // 기존 인사이트 삭제
      final oldInsight = await DatabaseService.getInsightByType(type);
      if (oldInsight != null) {
        await DatabaseService.deleteInsight(oldInsight.id);
      }

      // 데이터베이스에 저장
      final now = DateTime.now();
      final insight = EmotionInsight(
        id: const Uuid().v4(),
        type: type,
        insightText: insightText,
        periodStart: startDate,
        periodEnd: endDate,
        createdAt: now,
      );

      await DatabaseService.insertInsight(insight);

      // 상태 업데이트
      if (mounted) {
        setState(() {
          _insights[type] = insightText;
          _lastGenerated[type] = now;
          _isGenerating[type] = false;
        });
      }
    } catch (e) {
      print('AI 인사이트 생성 오류 ($type): $e');
      if (mounted) {
        setState(() {
          _isGenerating[type] = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diariesAsync = ref.watch(diaryEntriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '감정 통계',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '주별'),
            Tab(text: '월별'),
            Tab(text: '연간'),
          ],
          indicatorColor: const Color(0xFF667EEA),
          labelColor: const Color(0xFF667EEA),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: diariesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류: $error'),
        ),
        data: (diaries) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildWeeklyView(diaries),
              _buildMonthlyView(diaries),
              _buildYearlyView(diaries),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyView(List<DiaryEntry> diaries) {
    final now = DateTime.now();
    // _selectedWeek가 0이면 이번주, -1이면 지난주, -2면 2주 전
    final startOfCurrentWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final startOfSelectedWeek = startOfCurrentWeek.add(Duration(days: _selectedWeek * 7));
    final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final weeklyDiaries = diaries.where((diary) {
      final diaryDate = DateTime(diary.createdAt.year, diary.createdAt.month, diary.createdAt.day);
      return (diaryDate.isAtSameMomentAs(startOfSelectedWeek) || diaryDate.isAfter(startOfSelectedWeek)) &&
             (diaryDate.isAtSameMomentAs(startOfSelectedWeek.add(const Duration(days: 6))) || diaryDate.isBefore(endOfSelectedWeek));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeekSelector(),
          const SizedBox(height: 24),
          _buildWeeklyInsight(weeklyDiaries, startOfSelectedWeek, endOfSelectedWeek),
          const SizedBox(height: 24),
          _buildWeeklyDetailedStats(weeklyDiaries),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(List<DiaryEntry> diaries) {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month + _selectedMonth);
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    final monthlyDiaries = diaries.where((diary) {
      return diary.createdAt.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             diary.createdAt.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 24),
          _buildMonthlyInsight(monthlyDiaries, startOfMonth, endOfMonth),
          const SizedBox(height: 24),
          _buildMonthlyDetailedStats(monthlyDiaries),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B73FF).withOpacity(0.1),
            const Color(0xFF9B59B6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B73FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedWeek--;
                });
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF6B73FF)),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: _showWeekPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today,
                        color: Color(0xFF6B73FF), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getWeekDisplayText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _selectedWeek < 0 ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _selectedWeek < 0 ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: IconButton(
              onPressed: _selectedWeek < 0 ? () {
                setState(() {
                  _selectedWeek++;
                });
              } : null,
              icon: Icon(
                Icons.chevron_right,
                color: _selectedWeek < 0 ? const Color(0xFF6B73FF) : Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth--;
                });
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF667EEA)),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range,
                        color: Color(0xFF667EEA), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getMonthDisplayText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _selectedMonth < 0 ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _selectedMonth < 0 ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: IconButton(
              onPressed: _selectedMonth < 0 ? () {
                setState(() {
                  _selectedMonth++;
                });
              } : null,
              icon: Icon(
                Icons.chevron_right,
                color: _selectedMonth < 0 ? const Color(0xFF667EEA) : Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsight(List<DiaryEntry> diaries, DateTime startDate, DateTime endDate) {
    final periodText = '${DateFormat('M/d').format(startDate)} ~ ${DateFormat('M/d').format(endDate)}';

    if (diaries.isEmpty) {
      return _buildEmptyInsight('$periodText\n이 기간에 작성된 일기가 없습니다.');
    }

    final emotions = diaries.map((d) => d.emotion).where((e) => e != null).cast<String>().toList();
    final emotionCounts = <String, int>{};
    for (final emotion in emotions) {
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    final mostFrequentEmotion = emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final avgEntriesPerDay = diaries.length / 7;

    return Column(
      children: [
        _buildInsightCard(
          title: '주간 감정 인사이트 ($periodText)',
          insights: [
            InsightItem(
              icon: Icons.favorite_outlined,
              title: '주요 감정',
              value: mostFrequentEmotion.key,
              subtitle: '${mostFrequentEmotion.value}번 기록됨',
              color: const Color(0xFF6B73FF),
            ),
            InsightItem(
              icon: Icons.edit_note_outlined,
              title: '일기 작성 빈도',
              value: '${diaries.length}편',
              subtitle: '하루 평균 ${avgEntriesPerDay.toStringAsFixed(1)}편',
              color: const Color(0xFF9B59B6),
            ),
            InsightItem(
              icon: Icons.palette_outlined,
              title: '감정 다양성',
              value: '${emotionCounts.length}가지',
              subtitle: '다양한 감정을 경험하셨네요',
              color: const Color(0xFF00D4AA),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard('weekly', diaries),
      ],
    );
  }

  Widget _buildMonthlyInsight(List<DiaryEntry> diaries, DateTime startDate, DateTime endDate) {
    final periodText = DateFormat('yyyy년 M월').format(startDate);

    if (diaries.isEmpty) {
      return _buildEmptyInsight('$periodText\n이 기간에 작성된 일기가 없습니다.');
    }

    final emotions = diaries.map((d) => d.emotion).where((e) => e != null).cast<String>().toList();
    final emotionCounts = <String, int>{};
    for (final emotion in emotions) {
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    final mostFrequentEmotion = emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final daysInMonth = endDate.day;
    final avgEntriesPerDay = diaries.length / daysInMonth;

    return Column(
      children: [
        _buildInsightCard(
          title: '월간 감정 인사이트 ($periodText)',
          insights: [
            InsightItem(
              icon: Icons.favorite_outlined,
              title: '주요 감정',
              value: mostFrequentEmotion.key,
              subtitle: '${mostFrequentEmotion.value}번 기록됨',
              color: const Color(0xFF6B73FF),
            ),
            InsightItem(
              icon: Icons.edit_note_outlined,
              title: '일기 작성 빈도',
              value: '${diaries.length}편',
              subtitle: '하루 평균 ${avgEntriesPerDay.toStringAsFixed(1)}편',
              color: const Color(0xFF9B59B6),
            ),
            InsightItem(
              icon: Icons.palette_outlined,
              title: '감정 다양성',
              value: '${emotionCounts.length}가지',
              subtitle: '풍부한 감정을 표현하셨어요',
              color: const Color(0xFF00D4AA),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard('monthly', diaries),
      ],
    );
  }

  Widget _buildInsightCard({required String title, required List<InsightItem> insights}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) => _buildInsightRow(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightRow(InsightItem insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight.icon,
              color: insight.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInsight(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getWeekDisplayText() {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final selectedWeekStart = currentWeekStart.add(Duration(days: _selectedWeek * 7));
    final selectedWeekEnd = selectedWeekStart.add(const Duration(days: 6));

    if (_selectedWeek == 0) {
      return '이번 주';
    } else if (_selectedWeek == -1) {
      return '지난 주';
    } else {
      // 날짜 범위 형태로 표시 (10월5일~10월11일)
      final startMonth = selectedWeekStart.month;
      final startDay = selectedWeekStart.day;
      final endMonth = selectedWeekEnd.month;
      final endDay = selectedWeekEnd.day;

      if (startMonth == endMonth) {
        // 같은 달인 경우
        return '${startMonth}월${startDay}일~${endDay}일';
      } else {
        // 다른 달인 경우
        return '${startMonth}월${startDay}일~${endMonth}월${endDay}일';
      }
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _getMonthDisplayText() {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month + _selectedMonth);

    if (_selectedMonth == 0) {
      return '이번 달';
    } else if (_selectedMonth == -1) {
      return '지난 달';
    } else {
      return '${selectedDate.year}년 ${selectedDate.month}월';
    }
  }

  void _showWeekPicker() async {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final selectedWeekStart = currentWeekStart.add(Duration(days: _selectedWeek * 7));

    int selectedYear = selectedWeekStart.year;
    int selectedWeekOfYear = _getWeekOfYear(selectedWeekStart);

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('년도/주차 선택'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: selectedYear > now.year - 2 ? () {
                          setDialogState(() {
                            selectedYear--;
                            selectedWeekOfYear = math.min(selectedWeekOfYear, _getWeeksInYear(selectedYear));
                          });
                        } : null,
                        icon: Icon(
                          Icons.chevron_left,
                          color: selectedYear > now.year - 2 ? const Color(0xFF6B73FF) : Colors.grey,
                        ),
                      ),
                      Text(
                        '$selectedYear년',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedYear < now.year ? () {
                          setDialogState(() {
                            selectedYear++;
                            selectedWeekOfYear = math.min(selectedWeekOfYear, _getWeeksInYear(selectedYear));
                          });
                        } : null,
                        icon: Icon(
                          Icons.chevron_right,
                          color: selectedYear < now.year ? const Color(0xFF6B73FF) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Week selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: selectedWeekOfYear > 1 ? () {
                          setDialogState(() {
                            selectedWeekOfYear--;
                          });
                        } : null,
                        icon: Icon(
                          Icons.chevron_left,
                          color: selectedWeekOfYear > 1 ? const Color(0xFF6B73FF) : Colors.grey,
                        ),
                      ),
                      Text(
                        '$selectedWeekOfYear주차',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedWeekOfYear < _getWeeksInYear(selectedYear) ? () {
                          setDialogState(() {
                            selectedWeekOfYear++;
                          });
                        } : null,
                        icon: Icon(
                          Icons.chevron_right,
                          color: selectedWeekOfYear < _getWeeksInYear(selectedYear) ? const Color(0xFF6B73FF) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Selected date display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: () {
                    final weekStart = _getWeekStartFromYearWeek(selectedYear, selectedWeekOfYear);
                    final weekEnd = weekStart.add(const Duration(days: 6));
                    return Text(
                      '선택: ${weekStart.month}월${weekStart.day}일 ~ ${weekEnd.month}월${weekEnd.day}일',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B73FF),
                      ),
                    );
                  }(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final weekStart = _getWeekStartFromYearWeek(selectedYear, selectedWeekOfYear);
                final weekDifference = weekStart.difference(currentWeekStart).inDays ~/ 7;
                Navigator.of(context).pop(weekDifference);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedWeek = result;
      });
    }
  }

  void _showMonthPicker() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final selectedMonthDate = DateTime(now.year, now.month + _selectedMonth);

    int selectedYear = selectedMonthDate.year;
    int selectedMonthNum = selectedMonthDate.month;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            '년월 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 년도 선택
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '년도',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: selectedYear > now.year - 2 ? () {
                              setDialogState(() {
                                selectedYear--;
                              });
                            } : null,
                            icon: Icon(
                              Icons.chevron_left,
                              color: selectedYear > now.year - 2 ? const Color(0xFF6B73FF) : Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80,
                            alignment: Alignment.center,
                            child: Text(
                              '$selectedYear',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: selectedYear < now.year ? () {
                              setDialogState(() {
                                selectedYear++;
                              });
                            } : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: selectedYear < now.year ? const Color(0xFF6B73FF) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 월 선택
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '월',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                if (selectedMonthNum > 1) {
                                  selectedMonthNum--;
                                } else {
                                  selectedMonthNum = 12;
                                  selectedYear--;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                          Container(
                            width: 80,
                            alignment: Alignment.center,
                            child: Text(
                              '${selectedMonthNum}월',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                final nextDate = DateTime(selectedYear, selectedMonthNum + 1);
                                if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(DateTime(now.year, now.month))) {
                                  if (selectedMonthNum < 12) {
                                    selectedMonthNum++;
                                  } else {
                                    selectedMonthNum = 1;
                                    selectedYear++;
                                  }
                                }
                              });
                            },
                            icon: Icon(
                              Icons.chevron_right,
                              color: DateTime(selectedYear, selectedMonthNum + 1).isAfter(now)
                                ? Colors.grey
                                : const Color(0xFF6B73FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 현재 선택된 날짜 표시
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '선택: $selectedYear년 $selectedMonthNum월',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B73FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final selectedDate = DateTime(selectedYear, selectedMonthNum);
                final monthDifference = (selectedDate.year - currentMonth.year) * 12 +
                                      (selectedDate.month - currentMonth.month);
                Navigator.of(context).pop(monthDifference);
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Color(0xFF6B73FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result;
      });
    }
  }

  // 주별 날짜 계산을 위한 헬퍼 메서드들
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final firstMondayOfYear = _getWeekStart(firstDayOfYear);
    final daysSinceFirstMonday = date.difference(firstMondayOfYear).inDays;
    return (daysSinceFirstMonday / 7).floor() + 1;
  }

  int _getWeeksInYear(int year) {
    final lastDayOfYear = DateTime(year, 12, 31);
    return _getWeekOfYear(lastDayOfYear);
  }

  Widget _buildYearlyView(List<DiaryEntry> diaries) {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year + _selectedYear);
    final startOfYear = DateTime(selectedDate.year, 1, 1);
    final endOfYear = DateTime(selectedDate.year, 12, 31, 23, 59, 59);

    final yearlyDiaries = diaries.where((diary) {
      return diary.createdAt.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
             diary.createdAt.isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildYearSelector(),
          const SizedBox(height: 24),
          _buildYearlyInsight(yearlyDiaries, startOfYear, endOfYear),
          const SizedBox(height: 24),
          _buildYearlyDetailedStats(yearlyDiaries),
        ],
      ),
    );
  }

  Widget _buildAllTimeInsight(List<DiaryEntry> diaries) {
    // 전체 감정 분석
    final emotionCounts = <String, int>{};
    for (final diary in diaries) {
      if (diary.emotion != null && diary.emotion!.isNotEmpty) {
        emotionCounts[diary.emotion!] = (emotionCounts[diary.emotion!] ?? 0) + 1;
      }
    }

    final mostFrequentEmotion = emotionCounts.isNotEmpty
        ? emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    final totalDiaries = diaries.length;
    final daysSinceFirst = totalDiaries > 0
        ? DateTime.now().difference(diaries.first.createdAt).inDays
        : 0;
    final averagePerMonth = totalDiaries > 0 && daysSinceFirst > 0
        ? (totalDiaries / daysSinceFirst * 30).round()
        : 0;

    return Column(
      children: [
        _buildInsightCard(
          title: '전체 감정 인사이트',
          insights: [
            if (mostFrequentEmotion != null && totalDiaries > 0)
              InsightItem(
                icon: Icons.favorite_outlined,
                title: '주요 감정',
                value: mostFrequentEmotion.key,
                subtitle: '${mostFrequentEmotion.value}회 (${((mostFrequentEmotion.value / totalDiaries) * 100).round()}%)',
                color: const Color(0xFF6B73FF),
              ),
            InsightItem(
              icon: Icons.edit_note_outlined,
              title: '일기 작성 빈도',
              value: '$totalDiaries개',
              subtitle: '지금까지 작성한 모든 일기',
              color: const Color(0xFF9B59B6),
            ),
            if (emotionCounts.isNotEmpty)
              InsightItem(
                icon: Icons.palette_outlined,
                title: '감정 다양성',
                value: '${emotionCounts.length}가지',
                subtitle: '다양한 감정을 표현하고 있어요',
                color: const Color(0xFF00D4AA),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard('all_time', diaries),
      ],
    );
  }

  // AI 인사이트 카드 생성 위젯
  Widget _buildAIInsightCard(String type, List<DiaryEntry> diaries) {
    final insightText = _insights[type];
    final isGenerating = _isGenerating[type] ?? false;
    final lastGenerated = _lastGenerated[type];

    // 타입에 따른 타이틀 결정
    String title;
    switch (type) {
      case 'weekly':
        title = '주간 AI 감정 분석';
        break;
      case 'monthly':
        title = '월간 AI 감정 분석';
        break;
      case 'yearly':
        title = '연간 AI 감정 분석';
        break;
      default:
        title = 'AI 감정 분석';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF6B73FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'AI가 감정을 분석하고 있습니다...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (insightText != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B73FF).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      insightText,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (lastGenerated != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '분석 시각: ${DateFormat('yyyy년 MM월 dd일 HH:mm').format(lastGenerated)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    diaries.isEmpty
                        ? '일기를 작성하면 AI 인사이트가 자동으로 생성됩니다'
                        : 'AI 인사이트가 자동으로 생성 중입니다...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DateTime _getWeekStartFromYearWeek(int year, int weekOfYear) {
    final firstDayOfYear = DateTime(year, 1, 1);
    final firstMondayOfYear = _getWeekStart(firstDayOfYear);
    return firstMondayOfYear.add(Duration(days: (weekOfYear - 1) * 7));
  }

  Widget _buildWeeklyDetailedStats(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final emotionCounts = <String, int>{};
    for (final diary in diaries) {
      if (diary.emotion != null && diary.emotion!.isNotEmpty) {
        emotionCounts[diary.emotion!] = (emotionCounts[diary.emotion!] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF6B73FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '감정 분포',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedEmotions.map((entry) {
            final totalCount = sortedEmotions.fold<int>(0, (sum, e) => sum + e.value);
            final percentage = totalCount > 0 ? (entry.value / totalCount * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${entry.value}회 ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? entry.value / totalCount : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B73FF)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthlyDetailedStats(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final emotionCounts = <String, int>{};
    for (final diary in diaries) {
      if (diary.emotion != null && diary.emotion!.isNotEmpty) {
        emotionCounts[diary.emotion!] = (emotionCounts[diary.emotion!] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '감정 분포',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedEmotions.map((entry) {
            final totalCount = sortedEmotions.fold<int>(0, (sum, e) => sum + e.value);
            final percentage = totalCount > 0 ? (entry.value / totalCount * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${entry.value}회 ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? entry.value / totalCount : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllTimeDetailedStats(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final emotionCounts = <String, int>{};
    for (final diary in diaries) {
      if (diary.emotion != null && diary.emotion!.isNotEmpty) {
        emotionCounts[diary.emotion!] = (emotionCounts[diary.emotion!] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF764BA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF764BA2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '전체 감정 분포',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedEmotions.map((entry) {
            final totalCount = sortedEmotions.fold<int>(0, (sum, e) => sum + e.value);
            final percentage = totalCount > 0 ? (entry.value / totalCount * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${entry.value}회 ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? entry.value / totalCount : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF764BA2)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year + _selectedYear);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF764BA2).withOpacity(0.1),
            const Color(0xFF667EEA).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF764BA2).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedYear--;
                });
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF764BA2)),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF764BA2), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedDate.year}년',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _selectedYear < 0 ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _selectedYear < 0 ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: IconButton(
              onPressed: _selectedYear < 0 ? () {
                setState(() {
                  _selectedYear++;
                });
              } : null,
              icon: Icon(
                Icons.chevron_right,
                color: _selectedYear < 0 ? const Color(0xFF764BA2) : Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyInsight(List<DiaryEntry> diaries, DateTime startDate, DateTime endDate) {
    final periodText = '${startDate.year}년';

    if (diaries.isEmpty) {
      return _buildEmptyInsight('$periodText\n이 기간에 작성된 일기가 없습니다.');
    }

    final emotions = diaries.map((d) => d.emotion).where((e) => e != null).cast<String>().toList();
    final emotionCounts = <String, int>{};
    for (final emotion in emotions) {
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    final mostFrequentEmotion = emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final avgEntriesPerMonth = diaries.length / 12;

    return Column(
      children: [
        _buildInsightCard(
          title: '연간 감정 인사이트 ($periodText)',
          insights: [
            InsightItem(
              icon: Icons.favorite_outlined,
              title: '주요 감정',
              value: mostFrequentEmotion.key,
              subtitle: '${mostFrequentEmotion.value}번 기록됨',
              color: const Color(0xFF764BA2),
            ),
            InsightItem(
              icon: Icons.edit_note_outlined,
              title: '일기 작성 빈도',
              value: '${diaries.length}편',
              subtitle: '월 평균 ${avgEntriesPerMonth.toStringAsFixed(1)}편',
              color: const Color(0xFF667EEA),
            ),
            InsightItem(
              icon: Icons.palette_outlined,
              title: '감정 다양성',
              value: '${emotionCounts.length}가지',
              subtitle: '한 해 동안 다양한 감정을 경험하셨어요',
              color: const Color(0xFF00D4AA),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard('yearly', diaries),
      ],
    );
  }

  Widget _buildYearlyDetailedStats(List<DiaryEntry> diaries) {
    if (diaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final emotionCounts = <String, int>{};
    for (final diary in diaries) {
      if (diary.emotion != null && diary.emotion!.isNotEmpty) {
        emotionCounts[diary.emotion!] = (emotionCounts[diary.emotion!] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF764BA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF764BA2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '연간 감정 분포',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sortedEmotions.map((entry) {
            final totalCount = sortedEmotions.fold<int>(0, (sum, e) => sum + e.value);
            final percentage = totalCount > 0 ? (entry.value / totalCount * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${entry.value}회 ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? entry.value / totalCount : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF764BA2)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

}

class InsightItem {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  InsightItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });
}