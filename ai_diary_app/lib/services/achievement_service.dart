import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/diary_entry.dart';
import '../utils/app_logger.dart';

/// 성취 서비스
class AchievementService {
  static const String _achievementsKey = 'achievements';
  static const String _lastWriteDateKey = 'last_write_date';
  static const String _consecutiveDaysKey = 'consecutive_days';

  /// 성취 목록 로드
  static Future<List<Achievement>> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);

      if (achievementsJson == null) {
        // 처음 실행 시 기본 성취 목록 생성
        final defaultAchievements = Achievement.createDefaults();
        await saveAchievements(defaultAchievements);
        return defaultAchievements;
      }

      final List<dynamic> jsonList = json.decode(achievementsJson);
      return jsonList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      AppLogger.log('성취 로드 오류: $e');
      return Achievement.createDefaults();
    }
  }

  /// 성취 목록 저장
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = achievements.map((a) => a.toJson()).toList();
      await prefs.setString(_achievementsKey, json.encode(jsonList));
    } catch (e) {
      AppLogger.log('성취 저장 오류: $e');
    }
  }

  /// 성취 확인 및 업데이트
  static Future<List<Achievement>> checkAndUpdateAchievements(
    List<DiaryEntry> allEntries,
  ) async {
    final achievements = await loadAchievements();
    final newlyUnlocked = <Achievement>[];

    // 1. 첫 일기 작성
    if (allEntries.isNotEmpty) {
      final firstDiary = _updateAchievement(
        achievements,
        AchievementType.firstDiary,
        1,
      );
      if (firstDiary != null) newlyUnlocked.add(firstDiary);
    }

    // 2. 첫 AI 이미지 생성
    final hasAiImage = allEntries.any((e) =>
        (e.generatedImageUrl != null && e.generatedImageUrl!.isNotEmpty) ||
        e.imageData != null);
    if (hasAiImage) {
      final firstAi = _updateAchievement(
        achievements,
        AchievementType.firstAiImage,
        1,
      );
      if (firstAi != null) newlyUnlocked.add(firstAi);
    }

    // 3. 첫 사진 업로드
    final hasPhoto = allEntries.any((e) => e.userPhotos.isNotEmpty);
    if (hasPhoto) {
      final firstPhoto = _updateAchievement(
        achievements,
        AchievementType.firstPhotoUpload,
        1,
      );
      if (firstPhoto != null) newlyUnlocked.add(firstPhoto);
    }

    // 4. 일기 개수 성취
    final totalCount = allEntries.length;
    if (totalCount >= 10) {
      final count10 = _updateAchievement(
        achievements,
        AchievementType.diaryCount10,
        totalCount,
      );
      if (count10 != null) newlyUnlocked.add(count10);
    }
    if (totalCount >= 50) {
      final count50 = _updateAchievement(
        achievements,
        AchievementType.diaryCount50,
        totalCount,
      );
      if (count50 != null) newlyUnlocked.add(count50);
    }
    if (totalCount >= 100) {
      final count100 = _updateAchievement(
        achievements,
        AchievementType.diaryCount100,
        totalCount,
      );
      if (count100 != null) newlyUnlocked.add(count100);
    }

    // 5. 모든 감정 경험 (8가지 주요 감정)
    final emotions = allEntries
        .map((e) => e.emotion)
        .where((e) => e != null && e.isNotEmpty)
        .toSet();
    final emotionCount = emotions.length;
    if (emotionCount >= 8) {
      final allEmotions = _updateAchievement(
        achievements,
        AchievementType.allEmotions,
        emotionCount,
      );
      if (allEmotions != null) newlyUnlocked.add(allEmotions);
    }

    // 6. 연속 작성일 체크
    final consecutiveDays = await _calculateConsecutiveDays(allEntries);
    AppLogger.log('현재 연속 작성일: $consecutiveDays일');

    if (consecutiveDays >= 7) {
      final streak7 = _updateAchievement(
        achievements,
        AchievementType.consecutiveDays7,
        consecutiveDays,
      );
      if (streak7 != null) newlyUnlocked.add(streak7);
    }
    if (consecutiveDays >= 14) {
      final streak14 = _updateAchievement(
        achievements,
        AchievementType.consecutiveDays14,
        consecutiveDays,
      );
      if (streak14 != null) newlyUnlocked.add(streak14);
    }
    if (consecutiveDays >= 30) {
      final streak30 = _updateAchievement(
        achievements,
        AchievementType.consecutiveDays30,
        consecutiveDays,
      );
      if (streak30 != null) newlyUnlocked.add(streak30);
    }

    // 저장
    await saveAchievements(achievements);

    return newlyUnlocked;
  }

  /// 특정 성취 업데이트 (새로 달성한 경우에만 반환)
  static Achievement? _updateAchievement(
    List<Achievement> achievements,
    AchievementType type,
    int progress,
  ) {
    final index = achievements.indexWhere((a) => a.type == type);
    if (index == -1) return null;

    final achievement = achievements[index];

    // 이미 달성한 경우
    if (achievement.isUnlocked) return null;

    // 진행률 업데이트
    final updated = achievement.copyWith(progress: progress);
    achievements[index] = updated;

    // 목표 달성 시 잠금 해제
    if (updated.progress >= updated.goal) {
      final unlocked = updated.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievements[index] = unlocked;
      AppLogger.log('🎉 새로운 성취 달성: ${unlocked.title}');
      return unlocked;
    }

    return null;
  }

  /// 연속 작성일 계산
  static Future<int> _calculateConsecutiveDays(List<DiaryEntry> entries) async {
    if (entries.isEmpty) return 0;

    // 날짜별로 그룹화
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 가장 최근 일기가 오늘이나 어제가 아니면 연속 끊김
    final lastEntry = sortedEntries.first;
    final lastEntryDate = DateTime(
      lastEntry.createdAt.year,
      lastEntry.createdAt.month,
      lastEntry.createdAt.day,
    );

    final daysSinceLastEntry = todayDate.difference(lastEntryDate).inDays;

    if (daysSinceLastEntry > 1) {
      // 연속 끊김
      AppLogger.log('연속 작성 끊김: 마지막 작성일로부터 $daysSinceLastEntry일 경과');
      return 0;
    }

    // 연속 작성일 카운트
    int consecutiveDays = 0;
    DateTime currentDate = todayDate;

    final uniqueDates = sortedEntries
        .map((e) => DateTime(
              e.createdAt.year,
              e.createdAt.month,
              e.createdAt.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final entryDate in uniqueDates) {
      final difference = currentDate.difference(entryDate).inDays;

      if (difference == 0) {
        consecutiveDays++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (difference == 1) {
        consecutiveDays++;
        currentDate = entryDate.subtract(const Duration(days: 1));
      } else {
        // 연속 끊김
        break;
      }
    }

    return consecutiveDays;
  }

  /// 현재 연속 작성일 가져오기
  static Future<int> getCurrentStreak(List<DiaryEntry> entries) async {
    return await _calculateConsecutiveDays(entries);
  }

  /// 성취 초기화 (디버깅용)
  static Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    await prefs.remove(_lastWriteDateKey);
    await prefs.remove(_consecutiveDaysKey);
    AppLogger.log('성취 시스템 초기화 완료');
  }
}
