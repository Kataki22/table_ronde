import 'package:flutter/material.dart';

/// Classe représentant les données complètes d'un thème
class AppThemeData {
  // Nom du thème
  final String name;
  final String id;

  // Couleurs de fond
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgInverse;
  final Color bgSurface;
  final Color bgSurfaceDark;
  final Color bgHover;
  final Color bgActive;
  final Color bgInput;

  // Couleurs de texte
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color textMuted;
  final Color textDisabled;

  // Bordures
  final Color borderLight;
  final Color borderMedium;
  final Color borderDark;
  final Color borderSubtle;

  // Couleurs de marque
  final Color colorBrand;
  final Color colorBrandDark;
  final Color colorBrandLight;

  // Couleur primaire
  final Color colorPrimary;
  final Color colorPrimaryDark;
  final Color colorPrimaryLight;

  // Couleurs secondaires (optionnel)
  final Color? colorSecondary;
  final Color? colorSecondaryDark;
  final Color? colorSecondaryLight;

  // Couleurs d'état
  final Color colorSuccess;
  final Color? colorSuccessDark;
  final Color? colorSuccessLight;

  final Color colorWarning;
  final Color? colorWarningDark;
  final Color? colorWarningLight;

  final Color colorDanger;
  final Color? colorDangerDark;
  final Color? colorDangerLight;

  final Color? colorInfo;
  final Color? colorInfoDark;
  final Color? colorInfoLight;

  // Statuts de présence
  final Color colorOnline;
  final Color colorIdle;
  final Color colorDnd;
  final Color colorOffline;

  // Couleurs des bulles de messages
  final Color msgBubbleSent;
  final Color msgBubbleReceived;

  const AppThemeData({
    required this.name,
    required this.id,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgInverse,
    required this.bgSurface,
    required this.bgSurfaceDark,
    required this.bgHover,
    required this.bgActive,
    required this.bgInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.textMuted,
    required this.textDisabled,
    required this.borderLight,
    required this.borderMedium,
    required this.borderDark,
    required this.borderSubtle,
    required this.colorBrand,
    required this.colorBrandDark,
    required this.colorBrandLight,
    required this.colorPrimary,
    required this.colorPrimaryDark,
    required this.colorPrimaryLight,
    this.colorSecondary,
    this.colorSecondaryDark,
    this.colorSecondaryLight,
    required this.colorSuccess,
    this.colorSuccessDark,
    this.colorSuccessLight,
    required this.colorWarning,
    this.colorWarningDark,
    this.colorWarningLight,
    required this.colorDanger,
    this.colorDangerDark,
    this.colorDangerLight,
    this.colorInfo,
    this.colorInfoDark,
    this.colorInfoLight,
    required this.colorOnline,
    required this.colorIdle,
    required this.colorDnd,
    required this.colorOffline,
    required this.msgBubbleSent,
    required this.msgBubbleReceived,
  });

  /// Thème Discord
  static const discord = AppThemeData(
    name: 'Discord',
    id: 'discord',
    bgPrimary: Color(0xFF36393F),
    bgSecondary: Color(0xFF2F3136),
    bgTertiary: Color(0xFF202225),
    bgInverse: Color(0xFFFFFFFF),
    bgSurface: Color(0xFF313338),
    bgSurfaceDark: Color(0xFF1E1F22),
    bgHover: Color(0xFF40444B),
    bgActive: Color(0xFF4F545C),
    bgInput: Color(0xFF40444B),
    textPrimary: Color(0xFFDCDDDE),
    textSecondary: Color(0xFFB9BBBE),
    textTertiary: Color(0xFF72767D),
    textInverse: Color(0xFF111B21),
    textMuted: Color(0xFF72767D),
    textDisabled: Color(0xFF6D6F78),
    borderLight: Color(0x0FFFFFFF),
    borderMedium: Color(0x14FFFFFF),
    borderDark: Color(0x1FFFFFFF),
    borderSubtle: Color(0xFF26272B),
    colorBrand: Color(0xFF5865F2),
    colorBrandDark: Color(0xFF4752C4),
    colorBrandLight: Color(0xFF7983F5),
    colorPrimary: Color(0xFF5865F2),
    colorPrimaryDark: Color(0xFF4752C4),
    colorPrimaryLight: Color(0xFF7983F5),
    colorSecondary: Color(0xFF4F545C),
    colorSecondaryDark: Color(0xFF40444B),
    colorSecondaryLight: Color(0xFF72767D),
    colorSuccess: Color(0xFF3BA55D),
    colorSuccessDark: Color(0xFF2D7D46),
    colorSuccessLight: Color(0xFF4BD37A),
    colorWarning: Color(0xFFFAA61A),
    colorWarningDark: Color(0xFFC27F13),
    colorWarningLight: Color(0xFFFFBF4A),
    colorDanger: Color(0xFFED4245),
    colorDangerDark: Color(0xFFC03537),
    colorDangerLight: Color(0xFFFF6B6E),
    colorInfo: Color(0xFF3390EC),
    colorInfoDark: Color(0xFF2B7CD3),
    colorInfoLight: Color(0xFF4AA3FF),
    colorOnline: Color(0xFF23A559),
    colorIdle: Color(0xFFFAA61A),
    colorDnd: Color(0xFFF23F43),
    colorOffline: Color(0xFF80848E),
    msgBubbleSent: Color(0xFF5865F2),
    msgBubbleReceived: Color(0xFF2E3035),
  );

  /// Thème WhatsApp Light
  static const whatsappLight = AppThemeData(
    name: 'WhatsApp Clair',
    id: 'whatsapp-light',
    bgPrimary: Color(0xFFFFFFFF),
    bgSecondary: Color(0xFFF0F2F5),
    bgTertiary: Color(0xFFE9EDEF),
    bgInverse: Color(0xFF111B21),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceDark: Color(0xFFF0F2F5),
    bgHover: Color(0xFFF5F6F6),
    bgActive: Color(0xFFD1D7DB),
    bgInput: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111B21),
    textSecondary: Color(0xFF667781),
    textTertiary: Color(0xFF8696A0),
    textInverse: Color(0xFFFFFFFF),
    textMuted: Color(0xFF8696A0),
    textDisabled: Color(0xFFA8B3B9),
    borderLight: Color(0xFFE9EDEF),
    borderMedium: Color(0xFFD1D7DB),
    borderDark: Color(0xFFC0C7CC),
    borderSubtle: Color(0xFFE9EDEF),
    colorBrand: Color(0xFF00A884),
    colorBrandDark: Color(0xFF008C6F),
    colorBrandLight: Color(0xFF06CF9C),
    colorPrimary: Color(0xFF00A884),
    colorPrimaryDark: Color(0xFF008C6F),
    colorPrimaryLight: Color(0xFF06CF9C),
    colorSuccess: Color(0xFF00A884),
    colorWarning: Color(0xFFF7B928),
    colorDanger: Color(0xFFEA0038),
    colorOnline: Color(0xFF00A884),
    colorIdle: Color(0xFFF7B928),
    colorDnd: Color(0xFFEA0038),
    colorOffline: Color(0xFF8696A0),
    msgBubbleSent: Color(0xFFD9FDD3),
    msgBubbleReceived: Color(0xFFFFFFFF),
  );

  /// Thème WhatsApp Dark
  static const whatsappDark = AppThemeData(
    name: 'WhatsApp Sombre',
    id: 'whatsapp-dark',
    bgPrimary: Color(0xFF111B21),
    bgSecondary: Color(0xFF202C33),
    bgTertiary: Color(0xFF0B141A),
    bgInverse: Color(0xFFFFFFFF),
    bgSurface: Color(0xFF202C33),
    bgSurfaceDark: Color(0xFF0B141A),
    bgHover: Color(0xFF2A3942),
    bgActive: Color(0xFF233138),
    bgInput: Color(0xFF2A3942),
    textPrimary: Color(0xFFE9EDEF),
    textSecondary: Color(0xFF8696A0),
    textTertiary: Color(0xFF667781),
    textInverse: Color(0xFF111B21),
    textMuted: Color(0xFF667781),
    textDisabled: Color(0xFF55636C),
    borderLight: Color(0x0FFFFFFF),
    borderMedium: Color(0x1AFFFFFF),
    borderDark: Color(0x24FFFFFF),
    borderSubtle: Color(0xFF0B141A),
    colorBrand: Color(0xFF00A884),
    colorBrandDark: Color(0xFF008C6F),
    colorBrandLight: Color(0xFF06CF9C),
    colorPrimary: Color(0xFF00A884),
    colorPrimaryDark: Color(0xFF008C6F),
    colorPrimaryLight: Color(0xFF06CF9C),
    colorSuccess: Color(0xFF00A884),
    colorWarning: Color(0xFFF7B928),
    colorDanger: Color(0xFFEA0038),
    colorOnline: Color(0xFF00A884),
    colorIdle: Color(0xFFF7B928),
    colorDnd: Color(0xFFEA0038),
    colorOffline: Color(0xFF667781),
    msgBubbleSent: Color(0xFF005C4B),
    msgBubbleReceived: Color(0xFF202C33),
  );

  /// Thème Telegram Light
  static const telegramLight = AppThemeData(
    name: 'Telegram Clair',
    id: 'telegram-light',
    bgPrimary: Color(0xFFFFFFFF),
    bgSecondary: Color(0xFFF4F4F5),
    bgTertiary: Color(0xFFE4E4E7),
    bgInverse: Color(0xFF0E0E0E),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceDark: Color(0xFFF4F4F5),
    bgHover: Color(0xFFF0F0F1),
    bgActive: Color(0xFFD4D4D8),
    bgInput: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF707579),
    textTertiary: Color(0xFFA8A8A8),
    textInverse: Color(0xFFFFFFFF),
    textMuted: Color(0xFFA8A8A8),
    textDisabled: Color(0xFFC0C0C0),
    borderLight: Color(0xFFE4E4E7),
    borderMedium: Color(0xFFD4D4D8),
    borderDark: Color(0xFFC4C4C8),
    borderSubtle: Color(0xFFE4E4E7),
    colorBrand: Color(0xFF3390EC),
    colorBrandDark: Color(0xFF2B7CD3),
    colorBrandLight: Color(0xFF4AA3FF),
    colorPrimary: Color(0xFF3390EC),
    colorPrimaryDark: Color(0xFF2B7CD3),
    colorPrimaryLight: Color(0xFF4AA3FF),
    colorSuccess: Color(0xFF00C73C),
    colorWarning: Color(0xFFFF9800),
    colorDanger: Color(0xFFE53935),
    colorOnline: Color(0xFF00C73C),
    colorIdle: Color(0xFFFF9800),
    colorDnd: Color(0xFFE53935),
    colorOffline: Color(0xFFA8A8A8),
    msgBubbleSent: Color(0xFFEFFFDE),
    msgBubbleReceived: Color(0xFFFFFFFF),
  );

  /// Thème Telegram Dark
  static const telegramDark = AppThemeData(
    name: 'Telegram Sombre',
    id: 'telegram-dark',
    bgPrimary: Color(0xFF212121),
    bgSecondary: Color(0xFF181818),
    bgTertiary: Color(0xFF0E0E0E),
    bgInverse: Color(0xFFFFFFFF),
    bgSurface: Color(0xFF181818),
    bgSurfaceDark: Color(0xFF0E0E0E),
    bgHover: Color(0xFF2B2B2B),
    bgActive: Color(0xFF353535),
    bgInput: Color(0xFF2B2B2B),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAAAAAA),
    textTertiary: Color(0xFF707579),
    textInverse: Color(0xFF0E0E0E),
    textMuted: Color(0xFF707579),
    textDisabled: Color(0xFF5A5A5A),
    borderLight: Color(0x0FFFFFFF),
    borderMedium: Color(0x1AFFFFFF),
    borderDark: Color(0x24FFFFFF),
    borderSubtle: Color(0xFF0E0E0E),
    colorBrand: Color(0xFF5288C1),
    colorBrandDark: Color(0xFF4A7AAD),
    colorBrandLight: Color(0xFF6CA0D1),
    colorPrimary: Color(0xFF5288C1),
    colorPrimaryDark: Color(0xFF4A7AAD),
    colorPrimaryLight: Color(0xFF6CA0D1),
    colorSuccess: Color(0xFF00C73C),
    colorWarning: Color(0xFFFF9800),
    colorDanger: Color(0xFFE53935),
    colorOnline: Color(0xFF00C73C),
    colorIdle: Color(0xFFFF9800),
    colorDnd: Color(0xFFE53935),
    colorOffline: Color(0xFF707579),
    msgBubbleSent: Color(0xFF2B5278),
    msgBubbleReceived: Color(0xFF182533),
  );

  /// Thème VS Code
  static const vscode = AppThemeData(
    name: 'VS Code',
    id: 'vscode',
    bgPrimary: Color(0xFF1E1E1E),
    bgSecondary: Color(0xFF252526),
    bgTertiary: Color(0xFF2D2D30),
    bgInverse: Color(0xFFFFFFFF),
    bgSurface: Color(0xFF252526),
    bgSurfaceDark: Color(0xFF1E1E1E),
    bgHover: Color(0xFF2A2D2E),
    bgActive: Color(0xFF37373D),
    bgInput: Color(0xFF2D2D30),
    textPrimary: Color(0xFFCCCCCC),
    textSecondary: Color(0xFF9D9D9D),
    textTertiary: Color(0xFF6E6E6E),
    textInverse: Color(0xFF1E1E1E),
    textMuted: Color(0xFF6E6E6E),
    textDisabled: Color(0xFF5A5A5A),
    borderLight: Color(0x0FFFFFFF),
    borderMedium: Color(0x1AFFFFFF),
    borderDark: Color(0x24FFFFFF),
    borderSubtle: Color(0xFF3E3E42),
    colorBrand: Color(0xFF007ACC),
    colorBrandDark: Color(0xFF1A85C6),
    colorBrandLight: Color(0xFF4AA3FF),
    colorPrimary: Color(0xFF007ACC),
    colorPrimaryDark: Color(0xFF1A85C6),
    colorPrimaryLight: Color(0xFF4AA3FF),
    colorSuccess: Color(0xFF4EC9B0),
    colorWarning: Color(0xFFDCDCAA),
    colorDanger: Color(0xFFF48771),
    colorOnline: Color(0xFF4EC9B0),
    colorIdle: Color(0xFFDCDCAA),
    colorDnd: Color(0xFFF48771),
    colorOffline: Color(0xFF6E6E6E),
    msgBubbleSent: Color(0xFF007ACC),
    msgBubbleReceived: Color(0xFF252526),
  );

  /// Liste de tous les thèmes disponibles
  static const List<AppThemeData> allThemes = [
    discord,
    whatsappLight,
    whatsappDark,
    telegramLight,
    telegramDark,
    vscode,
  ];

  /// Obtenir un thème par son ID
  static AppThemeData getThemeById(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => discord, // Thème par défaut
    );
  }
}
