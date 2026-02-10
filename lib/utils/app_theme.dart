import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_data.dart';

class AppTheme {
  //Kept for backward compatibility
  static const Color primaryBlue = Color(0xFF5865F2);
  static const Color lightBlue = Color(0xFF7289DA);
  static const Color darkBlue = Color(0xFF4752C4);

  static const Color backgroundDark = Color(0xFF36393F);
  static const Color surfaceDark = Color(0xFF2F3136);
  static const Color cardDark = Color(0xFF202225);

  static const Color backgroundColor = Color(0xFFF2F3F5);
  static const Color cardBackground = Colors.white;

  static const Color textPrimary = Color(0xFFDCDDDE);
  static const Color textSecondary = Color(0xFF96989D);
  static const Color textDark = Color(0xFF2E3338);

  static const Color errorColor = Color(0xFFED4245);
  static const Color successColor = Color(0xFF3BA55D);
  static const Color onlineGreen = Color(0xFF3BA55D);
  static const Color warningColor = Color(0xFFFAA81A);

  static const Color telegramBlue = Color(0xFF0088CC);
  static const Color telegramGreen = Color(0xFF34C759);
  static const Color chatBubbleOutgoing = Color(0xFF0088CC);
  static const Color chatBubbleIncoming = Color(0xFF40444B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5865F2), Color(0xFF4752C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient discordGradient = LinearGradient(
    colors: [Color(0xFF7289DA), Color(0xFF5865F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient telegramBubbleGradient = LinearGradient(
    colors: [Color(0xFF0088CC), Color(0xFF0077B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Helper functions to create text styles
  static TextStyle _headingLarge(Color color) => GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle _headingMedium(Color color) => GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle _headingSmall(Color color) => GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle _bodyLarge(Color color) => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle _bodyMedium(Color color) => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle _bodySmall(Color color) => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
      );

  // Backward compatibility getters
  static TextStyle get headingLarge => _headingLarge(textPrimary);
  static TextStyle get headingMedium => _headingMedium(textPrimary);
  static TextStyle get headingSmall => _headingSmall(textPrimary);
  static TextStyle get bodyLarge => _bodyLarge(textPrimary);
  static TextStyle get bodyMedium => _bodyMedium(textSecondary);
  static TextStyle get bodySmall => _bodySmall(textSecondary);
  static TextStyle get buttonText => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  /// Génère un ThemeData à partir d'un AppThemeData
  static ThemeData generateThemeData(AppThemeData themeData) {
    final bool isLight = themeData.bgPrimary.computeLuminance() > 0.5;

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColor: themeData.colorPrimary,
      scaffoldBackgroundColor: themeData.bgPrimary,
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: themeData.colorPrimary,
        onPrimary: Colors.white,
        secondary: themeData.colorSecondary ?? themeData.colorPrimary,
        onSecondary: Colors.white,
        error: themeData.colorDanger,
        onError: Colors.white,
        background: themeData.bgPrimary,
        onBackground: themeData.textPrimary,
        surface: themeData.bgSurface,
        onSurface: themeData.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeData.bgTertiary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _headingMedium(themeData.textPrimary),
        iconTheme: IconThemeData(color: themeData.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: themeData.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeData.bgInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: themeData.colorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: themeData.colorDanger, width: 1),
        ),
        hintStyle: _bodyMedium(themeData.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeData.colorPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: buttonText,
        ),
      ),
      iconTheme: IconThemeData(
        color: themeData.textPrimary,
        size: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: themeData.bgTertiary,
        indicatorColor: themeData.colorPrimary.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          _bodySmall(themeData.textSecondary).copyWith(fontSize: 12),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: themeData.colorPrimary);
          }
          return IconThemeData(color: themeData.textSecondary);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: themeData.borderLight,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: themeData.bgSurface,
        textColor: themeData.textPrimary,
        iconColor: themeData.textPrimary,
      ),
    );
  }

  // Backward compatibility - default themes
  static ThemeData get lightTheme =>
      generateThemeData(AppThemeData.whatsappLight);
  static ThemeData get darkTheme => generateThemeData(AppThemeData.discord);
}
