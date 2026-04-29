import 'dart:ui';

import '../tokens/colors.dart';

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color scaffold;
  final Color textPrimary;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.scaffold,
    required this.textPrimary,
  });

  /// Light
  factory AppColors.light() {
    return const AppColors(
      primary: ColorTokens.blue500,
      secondary: ColorTokens.violet500,
      background: Color(0xFFF5F7FF),
      scaffold: Color(0xFFFFFFFF),
      textPrimary: ColorTokens.black,
    );
  }

  /// Dark
  factory AppColors.dark() {
    return const AppColors(
      primary: ColorTokens.violet500,
      secondary: ColorTokens.blue500,
      background: ColorTokens.gray900,
      scaffold: ColorTokens.gray800,
      textPrimary: ColorTokens.white,
    );
  }
}
