import 'package:flutter/material.dart';
import 'semantic/app_colors.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  ThemeData get theme {
    final colors = _isDark ? AppColors.dark() : AppColors.light();

    return _isDark ? DarkTheme.build(colors) : LightTheme.build(colors);
  }
}
