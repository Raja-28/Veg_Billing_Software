import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==============================
/// 🎨 Theme Provider
/// ==============================
/// Manages app theme (light/dark mode)

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', mode == ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Light theme data
FluentThemeData getLightTheme() {
  return FluentThemeData(
    brightness: Brightness.light,
    accentColor: Colors.green,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFF5F5F5),
  );
}

/// Dark theme data
FluentThemeData getDarkTheme() {
  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.green,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardColor: const Color(0xFF2A2A2A),
  );
}
