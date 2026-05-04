import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final isRamadanModeProvider = StateProvider<bool>((ref) => false);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.themeKey);
    if (stored == 'dark') {
      state = ThemeMode.dark;
    } else if (stored == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }
}

ThemeData resolveTheme(ThemeMode mode, Brightness platformBrightness, bool isRamadan) {
  if (isRamadan) return AppTheme.ramadan;
  switch (mode) {
    case ThemeMode.dark:
      return AppTheme.dark;
    case ThemeMode.light:
      return AppTheme.light;
    case ThemeMode.system:
      return platformBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
  }
}
