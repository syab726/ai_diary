import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/annual_report.dart';
import '../models/diary_entry.dart';
import '../services/annual_report_service.dart';
import '../services/database_service.dart';
import '../utils/app_logger.dart';

class AnnualReportScreen extends ConsumerStatefulWidget {
  const AnnualReportScreen({super.key});

  @override
  ConsumerState<AnnualReportScreen> createState() =>
      _AnnualReportScreenState();
}

class _AnnualReportScreenState extends ConsumerState<AnnualReportScreen> {
  int? _selectedYear;
  AnnualReport? _report;
  bool _isLoading = false;
  List<DiaryEntry> _bestDiaries = [];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (_selectedYear == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 기존 리포트 확인
      AnnualReport? existingReport =
          await AnnualReportService.loadAnnualReport(_selectedYear!);

      // 일기 데이터 가져오기
      final allEntries = await DatabaseService.getAllDiaries();

      // 리포트가 없거나 오래된 경우 새로 생성
      if (existingReport == null ||
          DateTime.now().difference(existingReport.generatedAt).inDays > 7) {
        existingReport = await AnnualReportService.generateAnnualReport(
          _selectedYear!,
          allEntries,
        );
      }

      // 베스트 일기 로드
      final bestDiaries = <DiaryEntry>[];
      for (final diaryId in existingReport.bestDiaryIds) {
        try {
          final diary = await DatabaseService.getDiaryById(diaryId);
          if (diary != null) {
            bestDiaries.add(diary);
          }
        } catch (e) {
          AppLogger.log('베스트 일기 로드 오류 ($diaryId): $e');
        }
      }

      if (mounted) {
        setState(() {
          _report = existingReport;
          _bestDiaries = bestDiaries;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.log('연간 리포트 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _regenerateReport() async {
    if (_selectedYear == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final allEntries = await DatabaseService.getAllDiaries();
      final newReport = await AnnualReportService.generateAnnualReport(
        _selectedYear!,
        allEntries,
        regenerateAI: true, // AI 요약 재생성
      );

      // 베스트 일기 로드
      final bestDiaries = <DiaryEntry>[];
      for (final diaryId in newReport.bestDiaryIds) {
        try {
          final diary = await DatabaseService.getDiaryById(diaryId);
          if (diary != null) {
            bestDiaries.add(diary);
          }
        } catch (e) {
          AppLogger.log('베스트 일기 로드 오류 ($diaryId): $e');
        }
      }

      if (mounted) {
        setState(() {
          _report = newReport;
          _bestDiaries = bestDiaries;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리포트가 새로 생성되었습니다')),
        );
      }
    } catch (e) {
      AppLogger.log('리포트 재생성 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리포트 생성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '연간 리포트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_report != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '리포트 재생성',
              onPressed: _isLoading ? null : _regenerateReport,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null || _report!.totalDiaries == 0
              ? _buildEmptyState()
              : _buildReportContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '$_selectedYear년에 작성된 일기가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일기를 작성하면 연말에 멋진 리포트를 받을 수 있어요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildYearSelector(),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_report == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYearSelector(),
          const SizedBox(height: 24),
          _buildOverviewCard(),
          const SizedBox(height: 16),
          if (_report!.aiSummary != null) ...[
            _buildAISummaryCard(),
            const SizedBox(height: 16),
          ],
          _buildEmotionCard(),
          const SizedBox(height: 16),
          _buildKeywordsCard(),
          const SizedBox(height: 16),
          if (_bestDiaries.isNotEmpty) ...[
            _buildBestDiariesCard(),
            const SizedBox(height: 16),
          ],
          _buildMonthlyActivityCard(),
          const SizedBox(height: 16),
          _buildWritingPatternsCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _selectedYear = _selectedYear! - 1;
                    });
                    _loadReport();
                  },
          ),
          GestureDetector(
            onTap: _showYearPicker,
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_selectedYear년',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _selectedYear! >= DateTime.now().year
                  ? Colors.white38
                  : Colors.white,
            ),
            onPressed: _isLoading ||
                    _selectedYear! >= DateTime.now().year
                ? null
                : () {
                    setState(() {
                      _selectedYear = _selectedYear! + 1;
                    });
                    _loadReport();
                  },
          ),
        ],
      ),
    );
  }

  void _showYearPicker() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('연도 선택'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text('$year년'),
                selected: year == _selectedYear,
                onTap: () => Navigator.pop(context, year),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null && selected != _selectedYear) {
      setState(() {
        _selectedYear = selected;
      });
      _loadReport();
    }
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            '한 해 요약',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '작성한 일기',
                  '${_report!.totalDiaries}개',
                  Icons.edit_note,
                  const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '기록한 날',
                  '${_report!.totalDaysWithDiary}일',
                  Icons.calendar_today,
                  const Color(0xFF9B59B6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '작성 비율',
                  '${(_report!.writingRatio * 100).toStringAsFixed(1)}%',
                  Icons.check_circle,
                  const Color(0xFF00D4AA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '월평균',
                  '${_report!.averageDiariesPerMonth.toStringAsFixed(1)}개',
                  Icons.trending_up,
                  const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI가 바라본 당신의 한 해',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _report!.aiSummary!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard() {
    final sortedEmotions = _report!.emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
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
          ...sortedEmotions.take(5).map((entry) {
            final percentage = (_report!.totalDiaries > 0
                    ? entry.value / _report!.totalDiaries
                    : 0.0) *
                100;
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
                        ),
                      ),
                      Text(
                        '${entry.value}회 (${percentage.toStringAsFixed(1)}%)',
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
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF667EEA)),
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

  Widget _buildKeywordsCard() {
    final topKeywords = _report!.topKeywords;

    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tag,
                  color: Color(0xFF00D4AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '자주 쓴 키워드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topKeywords.map((entry) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00D4AA).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${entry.key} (${entry.value})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00D4AA),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBestDiariesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFF6B6B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '베스트 일기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bestDiaries.length,
              itemBuilder: (context, index) {
                final diary = _bestDiaries[index];
                return GestureDetector(
                  onTap: () => context.push('/detail/${diary.id}'),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diary.generatedImageUrl != null &&
                            diary.generatedImageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              diary.generatedImageUrl!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diary.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diary.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF9B59B6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '월별 활동',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(12, (index) {
                final month = index + 1;
                final count = _report!.monthlyDiaryCounts[month] ?? 0;
                final maxCount = _report!.monthlyDiaryCounts.values
                    .reduce((a, b) => a > b ? a : b);
                final height = maxCount > 0 ? (count / maxCount) * 100 : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9B59B6),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$month',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_report!.mostActiveMonth != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '가장 활발했던 달: ${_report!.mostActiveMonth}월 (${_report!.monthlyDiaryCounts[_report!.mostActiveMonth]}개)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9B59B6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWritingPatternsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF00D4AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '작성 패턴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_report!.mostActiveDay != null) ...[
            _buildPatternRow(
              '가장 많이 쓴 요일',
              AnnualReportService.getDayName(_report!.mostActiveDay!),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
          ],
          if (_report!.mostActiveHour != null) ...[
            _buildPatternRow(
              '자주 쓰는 시간대',
              AnnualReportService.getTimeOfDayName(_report!.mostActiveHour!),
              Icons.access_time,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D4AA).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4AA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D4AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
