import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF159B9B);
  static const navy = Color(0xFF102C50);
  static const lightBackground = Color(0xFFF5F8FA);
  static const success = Color(0xFF249B65);
  static const warning = Color(0xFFE6A23C);
  static const error = Color(0xFFD9534F);
}

class AppTheme {
  /// In high-contrast mode the primary colour switches from teal to navy,
  /// because white text on #159B9B is only ~3.4:1.
  static ThemeData light({bool highContrast = false}) {
    final primary = highContrast ? AppColors.navy : AppColors.teal;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: AppColors.navy,
      onSecondary: Colors.white,
      error: AppColors.error,
      surface: Colors.white,
      onSurface: highContrast ? Colors.black : AppColors.navy,
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          highContrast ? Colors.white : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: shape,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: shape,
          side: BorderSide(color: primary, width: highContrast ? 2.5 : 1.5),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.onSurface.withOpacity(0.4)),
        ),
      ),
    );
  }
}
