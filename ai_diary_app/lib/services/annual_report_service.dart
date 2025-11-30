import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/annual_report.dart';
import '../services/ai_service.dart';
import '../utils/app_logger.dart';

class AnnualReportService {
  static const String _reportKeyPrefix = 'annual_report_';

  /// 특정 연도의 연간 리포트 생성
  static Future<AnnualReport> generateAnnualReport(
    int year,
    List<DiaryEntry> allEntries, {
    bool regenerateAI = false,
  }) async {
    // 해당 연도의 일기만 필터링
    final yearEntries = allEntries.where((entry) {
      return entry.createdAt.year == year;
    }).toList();

    if (yearEntries.isEmpty) {
      return AnnualReport(
        year: year,
        totalDiaries: 0,
        totalDaysWithDiary: 0,
        emotionCounts: {},
        keywordCounts: {},
        bestDiaryIds: [],
        monthlyDiaryCounts: {},
        dayOfWeekCounts: {},
        hourOfDayCounts: {},
        generatedAt: DateTime.now(),
      );
    }

    // 감정 분석
    final emotionCounts = <String, int>{};
    for (final entry in yearEntries) {
      if (entry.emotion != null && entry.emotion!.isNotEmpty) {
        emotionCounts[entry.emotion!] =
            (emotionCounts[entry.emotion!] ?? 0) + 1;
      }
    }

    // 키워드 분석
    final keywordCounts = <String, int>{};
    for (final entry in yearEntries) {
      for (final keyword in entry.keywords) {
        keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
      }
    }

    // 월별 일기 수
    final monthlyDiaryCounts = <int, int>{};
    for (int month = 1; month <= 12; month++) {
      monthlyDiaryCounts[month] = yearEntries
          .where((entry) => entry.createdAt.month == month)
          .length;
    }

    // 요일별 일기 수 (1=월요일, 7=일요일)
    final dayOfWeekCounts = <int, int>{};
    for (int day = 1; day <= 7; day++) {
      dayOfWeekCounts[day] = yearEntries
          .where((entry) => entry.createdAt.weekday == day)
          .length;
    }

    // 시간대별 일기 수
    final hourOfDayCounts = <int, int>{};
    for (int hour = 0; hour < 24; hour++) {
      hourOfDayCounts[hour] = yearEntries
          .where((entry) => entry.createdAt.hour == hour)
          .length;
    }

    // 일기 쓴 날짜 수 계산
    final uniqueDates = <DateTime>{};
    for (final entry in yearEntries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      uniqueDates.add(date);
    }

    // 베스트 일기 선정 (AI 이미지가 있는 일기 중 무작위 3개)
    final diariesWithImages = yearEntries
        .where((entry) =>
            (entry.generatedImageUrl != null && entry.generatedImageUrl!.isNotEmpty) ||
            entry.imageData != null)
        .toList();
    diariesWithImages.shuffle();
    final bestDiaryIds = diariesWithImages
        .take(3)
        .map((entry) => entry.id)
        .toList();

    // 기존 리포트 확인 (AI 요약 재사용)
    String? aiSummary;
    if (!regenerateAI) {
      final existingReport = await loadAnnualReport(year);
      aiSummary = existingReport?.aiSummary;
    }

    // AI 요약이 없으면 생성
    if (aiSummary == null) {
      try {
        aiSummary = await _generateAISummary(year, yearEntries, emotionCounts, keywordCounts);
      } catch (e) {
        AppLogger.log('AI 연간 요약 생성 실패: $e');
        aiSummary = null;
      }
    }

    final report = AnnualReport(
      year: year,
      totalDiaries: yearEntries.length,
      totalDaysWithDiary: uniqueDates.length,
      emotionCounts: emotionCounts,
      keywordCounts: keywordCounts,
      bestDiaryIds: bestDiaryIds,
      monthlyDiaryCounts: monthlyDiaryCounts,
      dayOfWeekCounts: dayOfWeekCounts,
      hourOfDayCounts: hourOfDayCounts,
      aiSummary: aiSummary,
      generatedAt: DateTime.now(),
    );

    // 리포트 저장
    await saveAnnualReport(report);

    return report;
  }

  /// AI 연간 요약 생성
  static Future<String> _generateAISummary(
    int year,
    List<DiaryEntry> entries,
    Map<String, int> emotionCounts,
    Map<String, int> keywordCounts,
  ) async {
    // 상위 감정과 키워드 추출
    final topEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topKeywords = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // AI에게 전달할 데이터 준비
    final summaryData = {
      'year': year,
      'totalDiaries': entries.length,
      'topEmotions': topEmotions.take(5).map((e) => {
        'emotion': e.key,
        'count': e.value,
      }).toList(),
      'topKeywords': topKeywords.take(10).map((k) => k.key).toList(),
      'monthlyPattern': entries.map((e) => e.createdAt.month).toList(),
    };

    // AI 서비스를 통해 연간 요약 생성
    final summary = await AIService.generateAnnualSummary(summaryData);
    return summary;
  }

  /// 연간 리포트 저장
  static Future<void> saveAnnualReport(AnnualReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_reportKeyPrefix${report.year}';
      final jsonString = jsonEncode(report.toJson());
      await prefs.setString(key, jsonString);
    } catch (e) {
      AppLogger.log('연간 리포트 저장 오류: $e');
    }
  }

  /// 연간 리포트 로드
  static Future<AnnualReport?> loadAnnualReport(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_reportKeyPrefix$year';
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AnnualReport.fromJson(json);
    } catch (e) {
      AppLogger.log('연간 리포트 로드 오류: $e');
      return null;
    }
  }

  /// 저장된 모든 연간 리포트의 년도 목록
  static Future<List<int>> getAvailableYears() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final years = keys
          .where((key) => key.startsWith(_reportKeyPrefix))
          .map((key) {
            final yearStr = key.substring(_reportKeyPrefix.length);
            return int.tryParse(yearStr);
          })
          .whereType<int>()
          .toList();

      years.sort((a, b) => b.compareTo(a)); // 최신 년도부터
      return years;
    } catch (e) {
      AppLogger.log('연도 목록 로드 오류: $e');
      return [];
    }
  }

  /// 리포트 삭제
  static Future<void> deleteAnnualReport(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_reportKeyPrefix$year';
      await prefs.remove(key);
    } catch (e) {
      AppLogger.log('연간 리포트 삭제 오류: $e');
    }
  }

  /// 요일 이름 반환 (1=월, 7=일)
  static String getDayName(int day) {
    const days = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[day];
  }

  /// 시간대 이름 반환
  static String getTimeOfDayName(int hour) {
    if (hour >= 5 && hour < 12) {
      return '오전 (5시-12시)';
    } else if (hour >= 12 && hour < 18) {
      return '오후 (12시-18시)';
    } else if (hour >= 18 && hour < 22) {
      return '저녁 (18시-22시)';
    } else {
      return '밤 (22시-5시)';
    }
  }
}
