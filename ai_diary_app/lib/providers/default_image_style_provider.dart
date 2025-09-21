import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_style.dart';

class DefaultImageStyleNotifier extends StateNotifier<ImageStyle> {
  DefaultImageStyleNotifier() : super(ImageStyle.realistic);

  void setStyle(ImageStyle style) {
    state = style;
  }
}

final defaultImageStyleProvider = StateNotifierProvider<DefaultImageStyleNotifier, ImageStyle>(
  (ref) => DefaultImageStyleNotifier(),
);