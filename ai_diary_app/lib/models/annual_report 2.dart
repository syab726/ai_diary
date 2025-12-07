import 'package:flutter/foundation.dart';

/// 연간 리포트 데이터 모델
class AnnualReport {
  final int year;
  final int totalDiaries;
  final int totalDaysWithDiary;
  final Map<String, int> emotionCounts;
  final Map<String, int> keywordCounts;
  final List<String> bestDiaryIds;
  final Map<int, int> monthlyDiaryCounts; // 월별 일기 수 (1~12)
  final Map<int, int> dayOfWeekCounts; // 요일별 일기 수 (1~7, 월~일)
  final Map<int, int> hourOfDayCounts; // 시간대별 일기 수 (0~23)
  final String? aiSummary; // AI가 생성한 올해의 요약
  final DateTime generatedAt;

  const AnnualReport({
    required this.year,
    required this.totalDiaries,
    required this.totalDaysWithDiary,
    required this.emotionCounts,
    required this.keywordCounts,
    required this.bestDiaryIds,
    required this.monthlyDiaryCounts,
    required this.dayOfWeekCounts,
    required this.hourOfDayCounts,
    this.aiSummary,
    required this.generatedAt,
  });

  /// 가장 많이 느낀 감정
  String? get mostFrequentEmotion {
    if (emotionCounts.isEmpty) return null;
    return emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 많이 쓴 키워드 (상위 10개)
  List<MapEntry<String, int>> get topKeywords {
    final sorted = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(10).toList();
  }

  /// 가장 활발했던 월
  int? get mostActiveMonth {
    if (monthlyDiaryCounts.isEmpty) return null;
    return monthlyDiaryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 많이 작성한 요일
  int? get mostActiveDay {
    if (dayOfWeekCounts.isEmpty) return null;
    return dayOfWeekCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 많이 작성한 시간대
  int? get mostActiveHour {
    if (hourOfDayCounts.isEmpty) return null;
    return hourOfDayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 작성 비율 (전체 날 중 일기 쓴 날)
  double get writingRatio {
    return totalDaysWithDiary / 365.0;
  }

  /// 일기 작성 빈도 (일/월)
  double get averageDiariesPerMonth {
    return totalDiaries / 12.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'totalDiaries': totalDiaries,
      'totalDaysWithDiary': totalDaysWithDiary,
      'emotionCounts': emotionCounts,
      'keywordCounts': keywordCounts,
      'bestDiaryIds': bestDiaryIds,
      'monthlyDiaryCounts':
          monthlyDiaryCounts.map((k, v) => MapEntry(k.toString(), v)),
      'dayOfWeekCounts':
          dayOfWeekCounts.map((k, v) => MapEntry(k.toString(), v)),
      'hourOfDayCounts':
          hourOfDayCounts.map((k, v) => MapEntry(k.toString(), v)),
      'aiSummary': aiSummary,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AnnualReport.fromJson(Map<String, dynamic> json) {
    return AnnualReport(
      year: json['year'] as int,
      totalDiaries: json['totalDiaries'] as int,
      totalDaysWithDiary: json['totalDaysWithDiary'] as int,
      emotionCounts: Map<String, int>.from(json['emotionCounts'] as Map),
      keywordCounts: Map<String, int>.from(json['keywordCounts'] as Map),
      bestDiaryIds: List<String>.from(json['bestDiaryIds'] as List),
      monthlyDiaryCounts: (json['monthlyDiaryCounts'] as Map)
          .map((k, v) => MapEntry(int.parse(k.toString()), v as int)),
      dayOfWeekCounts: (json['dayOfWeekCounts'] as Map)
          .map((k, v) => MapEntry(int.parse(k.toString()), v as int)),
      hourOfDayCounts: (json['hourOfDayCounts'] as Map)
          .map((k, v) => MapEntry(int.parse(k.toString()), v as int)),
      aiSummary: json['aiSummary'] as String?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  AnnualReport copyWith({
    int? year,
    int? totalDiaries,
    int? totalDaysWithDiary,
    Map<String, int>? emotionCounts,
    Map<String, int>? keywordCounts,
    List<String>? bestDiaryIds,
    Map<int, int>? monthlyDiaryCounts,
    Map<int, int>? dayOfWeekCounts,
    Map<int, int>? hourOfDayCounts,
    String? aiSummary,
    DateTime? generatedAt,
  }) {
    return AnnualReport(
      year: year ?? this.year,
      totalDiaries: totalDiaries ?? this.totalDiaries,
      totalDaysWithDiary: totalDaysWithDiary ?? this.totalDaysWithDiary,
      emotionCounts: emotionCounts ?? this.emotionCounts,
      keywordCounts: keywordCounts ?? this.keywordCounts,
      bestDiaryIds: bestDiaryIds ?? this.bestDiaryIds,
      monthlyDiaryCounts: monthlyDiaryCounts ?? this.monthlyDiaryCounts,
      dayOfWeekCounts: dayOfWeekCounts ?? this.dayOfWeekCounts,
      hourOfDayCounts: hourOfDayCounts ?? this.hourOfDayCounts,
      aiSummary: aiSummary ?? this.aiSummary,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnnualReport &&
        other.year == year &&
        other.totalDiaries == totalDiaries &&
        other.totalDaysWithDiary == totalDaysWithDiary &&
        mapEquals(other.emotionCounts, emotionCounts) &&
        mapEquals(other.keywordCounts, keywordCounts) &&
        listEquals(other.bestDiaryIds, bestDiaryIds) &&
        mapEquals(other.monthlyDiaryCounts, monthlyDiaryCounts) &&
        mapEquals(other.dayOfWeekCounts, dayOfWeekCounts) &&
        mapEquals(other.hourOfDayCounts, hourOfDayCounts) &&
        other.aiSummary == aiSummary &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return year.hashCode ^
        totalDiaries.hashCode ^
        totalDaysWithDiary.hashCode ^
        emotionCounts.hashCode ^
        keywordCounts.hashCode ^
        bestDiaryIds.hashCode ^
        monthlyDiaryCounts.hashCode ^
        dayOfWeekCounts.hashCode ^
        hourOfDayCounts.hashCode ^
        aiSummary.hashCode ^
        generatedAt.hashCode;
  }
}
