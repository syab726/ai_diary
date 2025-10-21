import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_preset.dart';

class ThemePresetNotifier extends StateNotifier<String?> {
  ThemePresetNotifier() : super(null) {
    _loadSelectedPreset();
  }

  Future<void> _loadSelectedPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetId = prefs.getString('selected_theme_preset');
      state = presetId;
    } catch (e) {
      if (kDebugMode) print('테마 프리셋 로드 오류: $e');
    }
  }

  Future<void> selectPreset(String? presetId) async {
    state = presetId;
    await _saveSelectedPreset(presetId);
  }

  Future<void> _saveSelectedPreset(String? presetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (presetId != null) {
        await prefs.setString('selected_theme_preset', presetId);
      } else {
        await prefs.remove('selected_theme_preset');
      }
    } catch (e) {
      if (kDebugMode) print('테마 프리셋 저장 오류: $e');
    }
  }

  ThemePreset? getCurrentPreset() {
    if (state == null) return null;
    return ThemePresets.findById(state!);
  }
}

final themePresetProvider = StateNotifierProvider<ThemePresetNotifier, String?>((ref) {
  return ThemePresetNotifier();
});