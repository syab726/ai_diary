import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('app_theme') ?? 'system';
    switch (themeString) {
      case 'light':
        state = AppThemeMode.light;
        break;
      case 'dark':
        state = AppThemeMode.dark;
        break;
      default:
        state = AppThemeMode.system;
        break;
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.toString().split('.').last);
  }
}

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('font_size') ?? 1.0;
  }

  Future<void> setFontSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }
}