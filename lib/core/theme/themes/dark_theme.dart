import 'package:flutter/material.dart';
import '../semantic/app_colors.dart';
import '../tokens/typography.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class DarkTheme {
  static ThemeData build(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.background,
      ),

      scaffoldBackgroundColor: colors.scaffold,

      textTheme: const TextTheme(
        bodyMedium: TypographyTokens.body,
        titleLarge: TypographyTokens.title,
      ).apply(bodyColor: colors.textPrimary),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.background.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: RadiusTokens.r16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(SpacingTokens.s16),
          shape: RoundedRectangleBorder(borderRadius: RadiusTokens.r12),
        ),
      ),
    );
  }
}
