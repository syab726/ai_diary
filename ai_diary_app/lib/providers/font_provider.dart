import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/font_family.dart';

class FontNotifier extends StateNotifier<FontFamily> {
  FontNotifier() : super(FontFamily.notoSans) {
    _loadFont();
  }

  static const String _fontKey = 'selected_font';

  Future<void> _loadFont() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fontName = prefs.getString(_fontKey);

      if (fontName != null) {
        final font = FontFamily.values.firstWhere(
          (f) => f.name == fontName,
          orElse: () => FontFamily.notoSans,
        );
        state = font;
      }
    } catch (e) {
      // 오류 시 기본 글꼴 유지
      state = FontFamily.notoSans;
    }
  }

  Future<void> setFont(FontFamily font) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontKey, font.name);
      state = font;
    } catch (e) {
      // 오류 시 기본 글꼴로 되돌림
      state = FontFamily.notoSans;
    }
  }

  Future<void> resetToDefault() async {
    await setFont(FontFamily.notoSans);
  }
}

final fontProvider = StateNotifierProvider<FontNotifier, FontFamily>((ref) {
  return FontNotifier();
});