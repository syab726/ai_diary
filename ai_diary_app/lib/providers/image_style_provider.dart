import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_style.dart';

final defaultImageStyleProvider = StateNotifierProvider<DefaultImageStyleNotifier, ImageStyle>((ref) {
  return DefaultImageStyleNotifier();
});

class DefaultImageStyleNotifier extends StateNotifier<ImageStyle> {
  DefaultImageStyleNotifier() : super(ImageStyle.auto) {
    _loadSavedStyle();
  }

  Future<void> _loadSavedStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('default_image_style') ?? 0;
    if (styleIndex >= 0 && styleIndex < ImageStyle.values.length) {
      state = ImageStyle.values[styleIndex];
    }
  }

  Future<void> setStyle(ImageStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_image_style', ImageStyle.values.indexOf(style));
  }
}