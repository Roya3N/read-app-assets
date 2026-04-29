import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFF3B82F6);

  static const background = Color(0xFF1E1E24);
  static const scaffold = Color(0xFF1A1A2E);

  static const textPrimary = Colors.white;
}

abstract final class AppRadii {
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
}

abstract final class AppSpacing {
  static const v8 = SizedBox(height: 8);
  static const v10 = SizedBox(height: 10);
  static const v12 = SizedBox(height: 12);
  static const v16 = SizedBox(height: 16);
  static const v20 = SizedBox(height: 20);
  static const v30 = SizedBox(height: 30);
  static const v40 = SizedBox(height: 40);
}
