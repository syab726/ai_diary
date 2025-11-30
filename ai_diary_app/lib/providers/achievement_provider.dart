import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../models/diary_entry.dart';
import '../services/achievement_service.dart';
import '../utils/app_logger.dart';

/// 성취 상태 Provider
final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier();
});

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super([]) {
    _loadAchievements();
  }

  /// 성취 로드
  Future<void> _loadAchievements() async {
    try {
      final achievements = await AchievementService.loadAchievements();
      state = achievements;
    } catch (e) {
      AppLogger.log('성취 로드 오류: $e');
    }
  }

  /// 성취 확인 및 업데이트
  Future<List<Achievement>> checkAndUpdate(List<DiaryEntry> entries) async {
    try {
      final newlyUnlocked =
          await AchievementService.checkAndUpdateAchievements(entries);

      // 상태 업데이트
      final updatedAchievements = await AchievementService.loadAchievements();
      state = updatedAchievements;

      return newlyUnlocked;
    } catch (e) {
      AppLogger.log('성취 체크 오류: $e');
      return [];
    }
  }

  /// 현재 연속 작성일 가져오기
  Future<int> getCurrentStreak(List<DiaryEntry> entries) async {
    return await AchievementService.getCurrentStreak(entries);
  }

  /// 성취 초기화 (디버깅용)
  Future<void> resetAchievements() async {
    await AchievementService.resetAchievements();
    await _loadAchievements();
  }

  /// 잠금 해제된 성취 개수
  int get unlockedCount => state.where((a) => a.isUnlocked).length;

  /// 전체 성취 개수
  int get totalCount => state.length;

  /// 달성률
  double get completionRate =>
      totalCount > 0 ? unlockedCount / totalCount : 0.0;
}

/// 현재 연속 작성일 Provider
final currentStreakProvider = FutureProvider<int>((ref) async {
  // 여기서는 임시로 0을 반환하고, 실제로는 다이어리 엔트리를 가져와서 계산해야 함
  return 0;
});
