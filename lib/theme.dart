import 'package:flutter/material.dart';

/// لوحة ألوان هادئة: أخضر مائل للزرقة، رملي دافئ، وخلفية كريمية.
class AppColors {
  static const primary = Color(0xFF3F7D7A);
  static const primarySoft = Color(0xFFD9EBE7);
  static const sand = Color(0xFFE3B66B);
  static const sandSoft = Color(0xFFF7EBD3);
  static const background = Color(0xFFF6F3EC);
  static const surface = Colors.white;
  static const ink = Color(0xFF22313A);
  static const muted = Color(0xFF6E7D82);
  static const line = Color(0xFFE6E1D6);
  static const success = Color(0xFF5E9E6E);
  static const successSoft = Color(0xFFE3F1E5);
  static const error = Color(0xFFC9665A);
  static const errorSoft = Color(0xFFF8E3DF);

  /// اللون الأحمر لتمييز (الـ) كما في تصميم الدرس.
  static const al = Color(0xFFD64545);

  static const moon = Color(0xFF6C7BB8);
  static const moonSoft = Color(0xFFE5E8F5);
  static const sun = Color(0xFFDB9A35);
  static const sunSoft = Color(0xFFFBEED6);
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
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
