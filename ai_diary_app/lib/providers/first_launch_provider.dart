import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 첫 실행 여부를 관리하는 Provider
final firstLaunchProvider = StateNotifierProvider<FirstLaunchNotifier, bool>((ref) {
  return FirstLaunchNotifier();
});

class FirstLaunchNotifier extends StateNotifier<bool> {
  static const String _firstLaunchKey = 'first_launch';

  FirstLaunchNotifier() : super(true) {
    _loadFirstLaunch();
  }

  Future<void> _loadFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 첫 실행이면 true (키가 없으면), 아니면 false
      state = !prefs.containsKey(_firstLaunchKey);
    } catch (e) {
      state = true; // 오류 시 첫 실행으로 간주
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, true);
      state = false; // 더 이상 첫 실행이 아님
    } catch (e) {
      // 에러 처리
    }
  }
}
