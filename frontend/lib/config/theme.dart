import 'package:flutter/material.dart';

class AppColors {
  // 메인 색상 초록 계열
  static const Color primaryLight = Color(0xFFA6D577);
  static const Color primary = Color(0xFF76C352); // 메인 색상 입니다.
  static const Color primaryDark = Color(0xFF189E1E);
  static const Color primaryDarkest = Color(0xFF07621C);

  // 회색 계열
  static const Color background = Color(0xFFFFFFFF);
  static const Color verylightGray = Color(0xFFF3F3F3); // 제일 연한 회색
  static const Color lightGray = Color(0xFFD9D9D9); // 연한 회색
  static const Color mediumGray = Color(0xFFB7B7B7); // 중간 회색
  static const Color darkGray = Color(0xFF434343); // 진한 회색
}

// 기본 텍스트 스타일
const TextStyle _baseTextStyle = TextStyle(
  fontFamily: 'Anemone_air',
  color: AppColors.darkGray,
  fontSize: 16,
);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Anemone_air',
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      background: AppColors.background,
    ),
    textTheme: TextTheme(
      bodyMedium: _baseTextStyle,
    ),
  );
}