import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme_data.dart';
import '../providers/theme_provider.dart';

/// Extension sur BuildContext pour accéder facilement aux couleurs du thème actuel
extension ThemeExtensions on BuildContext {
  /// Retourne l'AppThemeData actif
  AppThemeData get themeColors {
    return watch<ThemeProvider>().currentTheme;
  }

  /// Retourne l'AppThemeData actif sans écouter les changements
  AppThemeData get themeColorsNoWatch {
    return read<ThemeProvider>().currentTheme;
  }
}
