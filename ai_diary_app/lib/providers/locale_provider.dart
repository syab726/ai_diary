import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// 현재 라우트를 저장하는 provider
final currentRouteProvider = StateProvider<String?>((ref) => null);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ko')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final locale = await AppLocalizations.getSavedLocale();
    state = locale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await AppLocalizations.setLocale(locale);
  }
}