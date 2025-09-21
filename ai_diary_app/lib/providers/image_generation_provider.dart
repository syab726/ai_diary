import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 이미지 생성 카운트 관리
class ImageGenerationState {
  final int monthlyCount;
  final int rewardedCount;
  final DateTime lastResetDate;

  ImageGenerationState({
    required this.monthlyCount,
    required this.rewardedCount,
    required this.lastResetDate,
  });

  ImageGenerationState copyWith({
    int? monthlyCount,
    int? rewardedCount,
    DateTime? lastResetDate,
  }) {
    return ImageGenerationState(
      monthlyCount: monthlyCount ?? this.monthlyCount,
      rewardedCount: rewardedCount ?? this.rewardedCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}

final imageGenerationProvider = StateNotifierProvider<ImageGenerationNotifier, ImageGenerationState>((ref) {
  return ImageGenerationNotifier();
});

class ImageGenerationNotifier extends StateNotifier<ImageGenerationState> {
  ImageGenerationNotifier() : super(ImageGenerationState(
    monthlyCount: 0,
    rewardedCount: 0,
    lastResetDate: DateTime.now(),
  )) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final monthlyCount = prefs.getInt('monthly_image_count') ?? 0;
    final rewardedCount = prefs.getInt('rewarded_image_count') ?? 0;
    final lastResetStr = prefs.getString('last_reset_date');
    final lastResetDate = lastResetStr != null 
        ? DateTime.parse(lastResetStr) 
        : DateTime.now();

    // 월이 바뀌었으면 카운트 리셋
    final now = DateTime.now();
    if (now.month != lastResetDate.month || now.year != lastResetDate.year) {
      await resetMonthlyCount();
    } else {
      state = ImageGenerationState(
        monthlyCount: monthlyCount,
        rewardedCount: rewardedCount,
        lastResetDate: lastResetDate,
      );
    }
  }

  Future<void> incrementMonthlyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.monthlyCount + 1;
    await prefs.setInt('monthly_image_count', newCount);
    state = state.copyWith(monthlyCount: newCount);
  }

  Future<void> incrementRewardedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.rewardedCount + 1;
    await prefs.setInt('rewarded_image_count', newCount);
    state = state.copyWith(rewardedCount: newCount);
  }

  Future<void> resetMonthlyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('monthly_image_count', 0);
    await prefs.setInt('rewarded_image_count', 0);
    await prefs.setString('last_reset_date', now.toIso8601String());
    
    state = ImageGenerationState(
      monthlyCount: 0,
      rewardedCount: 0,
      lastResetDate: now,
    );
  }

  bool canGenerateImage(bool isPremium) {
    if (isPremium) return true;
    return state.monthlyCount < 5 || state.rewardedCount > 0;
  }

  Future<void> useRewardedImage() async {
    if (state.rewardedCount > 0) {
      final prefs = await SharedPreferences.getInstance();
      final newCount = state.rewardedCount - 1;
      await prefs.setInt('rewarded_image_count', newCount);
      state = state.copyWith(rewardedCount: newCount);
    }
  }

  int getRemainingFreeImages() {
    return 5 - state.monthlyCount;
  }
}