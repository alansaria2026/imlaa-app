import 'package:flutter/material.dart';

/// لوحة ألوان مقتصدة: أبيض وأسود، والأحمر والأزرق لتمييز الحروف فقط.
class AppColors {
  static const black = Color(0xFF111111);
  static const red = Color(0xFFD32F2F);
  static const blue = Color(0xFF1E5BD8);

  static const primary = black;
  static const primaryDark = Color(0xFF000000);
  static const primarySoft = Color(0xFFF1F1F1);
  static const sand = black;
  static const sandDark = black;
  static const sandSoft = Color(0xFFF1F1F1);
  static const background = Colors.white;
  static const surface = Colors.white;
  static const ink = black;
  static const muted = Color(0xFF6B6B6B);
  static const line = Color(0xFFE0E0E0);
  static const lineDark = Color(0xFFBDBDBD);
  static const success = blue;
  static const successDark = Color(0xFF16449F);
  static const successSoft = Color(0xFFEAF0FC);
  static const error = red;
  static const errorDark = Color(0xFFA32424);
  static const errorSoft = Color(0xFFFCECEC);
  static const streak = black;
  static const locked = Color(0xFFEDEDED);

  /// نسخة أغمق من اللون لحافة الأزرار ثلاثية الأبعاد.
  static Color darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// اللون الأحمر لتمييز (الـ) كما في تصميم الدرس.
  static const al = red;

  static const moon = blue;
  static const moonSoft = Color(0xFFF1F1F1);
  static const sun = red;
  static const sunSoft = Color(0xFFF1F1F1);
}

class AppTheme {
  static TextStyle word(double size, {Color color = AppColors.ink}) =>
      TextStyle(
        fontFamily: 'NotoNaskhArabic',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.6,
      );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.sand,
      surface: AppColors.surface,
      error: AppColors.error,
    );
    final text = Typography.material2021().black.apply(
      fontFamily: 'Tajawal',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: rounded,
          textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: rounded,
          side: const BorderSide(color: AppColors.line, width: 1.5),
          foregroundColor: AppColors.ink,
          textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
        contentTextStyle: text.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }
}
