import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Locale locale;
  final Color? primaryColor;
  final double? borderRadius;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.primaryColor,
    this.borderRadius,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    Color? primaryColor,
    double? borderRadius,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      primaryColor: primaryColor ?? this.primaryColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _themeModeKey = 'escalated_theme_mode';
  static const _localeKey = 'escalated_locale';
  final FlutterSecureStorage _storage;

  ThemeNotifier({
    FlutterSecureStorage? storage,
    Color? primaryColor,
    double? borderRadius,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        super(ThemeState(
          primaryColor: primaryColor,
          borderRadius: borderRadius,
        )) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final themeModeStr = await _storage.read(key: _themeModeKey);
      final localeStr = await _storage.read(key: _localeKey);

      ThemeMode themeMode = ThemeMode.system;
      if (themeModeStr == 'light') {
        themeMode = ThemeMode.light;
      } else if (themeModeStr == 'dark') {
        themeMode = ThemeMode.dark;
      }

      Locale locale = const Locale('en');
      if (localeStr != null && localeStr.isNotEmpty) {
        locale = Locale(localeStr);
      }

      state = state.copyWith(themeMode: themeMode, locale: locale);
    } catch (_) {
      // Use defaults if storage fails
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await _storage.write(key: _themeModeKey, value: value);
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _storage.write(key: _localeKey, value: locale.languageCode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
