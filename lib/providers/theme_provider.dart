import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme_data.dart';

/// Provider pour gérer le thème de l'application
class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'selected_theme_id';

  AppThemeData _currentTheme = AppThemeData.discord;

  AppThemeData get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  /// Charge le thème sauvegardé depuis les préférences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeId = prefs.getString(_themePreferenceKey);

      if (themeId != null) {
        _currentTheme = AppThemeData.getThemeById(themeId);
        notifyListeners();
      }
    } catch (e) {
      // En cas d'erreur, utiliser le thème par défaut
      debugPrint('Error loading theme: $e');
    }
  }

  /// Change le thème et le sauvegarde
  Future<void> setTheme(AppThemeData theme) async {
    if (_currentTheme.id == theme.id) return;

    _currentTheme = theme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, theme.id);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Change le thème par ID
  Future<void> setThemeById(String themeId) async {
    final theme = AppThemeData.getThemeById(themeId);
    await setTheme(theme);
  }
}
