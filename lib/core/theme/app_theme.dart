import 'package:flutter/material.dart';

// 🎨 Color System (Scalable)
class AppColors {
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFF3B82F6);
  static const background = Color(0xFF1E1E24);
  static const scaffold = Color(0xFF1A1A2E);
  static const textPrimary = Colors.white;
}

// 🎯 Theme System
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
    ),

    scaffoldBackgroundColor: AppColors.scaffold,

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.background.withOpacity(0.95),
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),

    // 💡 آماده برای توسعه
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
    ),
  );
}
