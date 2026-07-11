import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

const _key = 'theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_key) ?? true;
    state = dark;
    isDarkMode = dark;
  }

  Future<void> toggle() async {
    state = !state;
    isDarkMode = state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  Future<void> setDark(bool dark) async {
    state = dark;
    isDarkMode = dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}
