import 'package:flutter/material.dart';

class AppTheme {
  // 색상 상수 정의
  static const Color primaryColor = Color(0xFF5B9FED);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color cardBackground = Colors.white;
  static const Color caloriesIconColor = Color(0xFFFF6B6B);
  
  // 앱 테마
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'NotoSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ),
    );
  }
}
  