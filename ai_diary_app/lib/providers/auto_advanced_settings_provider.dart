import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoAdvancedSettingsNotifier extends StateNotifier<bool> {
  AutoAdvancedSettingsNotifier() : super(false) {
    _loadSetting();
  }

  static const String _key = 'auto_advanced_settings';

  Future<void> _loadSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? false;
    } catch (e) {
      print('고급설정 자동설정 로드 오류: $e');
      state = false;
    }
  }

  Future<void> setAutoAdvancedSettings(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled);
      state = enabled;
    } catch (e) {
      print('고급설정 자동설정 저장 오류: $e');
    }
  }

  Future<void> toggle() async {
    await setAutoAdvancedSettings(!state);
  }
}

final autoAdvancedSettingsProvider = StateNotifierProvider<AutoAdvancedSettingsNotifier, bool>((ref) {
  return AutoAdvancedSettingsNotifier();
});