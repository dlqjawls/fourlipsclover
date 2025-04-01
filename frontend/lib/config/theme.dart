import 'package:flutter/material.dart';

class AppColors {
  // 메인 색상 초록 계열
  static const Color primaryLight = Color(0xFFA6D577);
  static const Color primary = Color(0xFF76C352); // 메인 색상 입니다.
  static const Color primaryDark = Color(0xFF189E1E);
  static const Color primaryDarkest = Color(0xFF07621C);

  // 레드
  static const Color red = Color(0xFFE63946);
  static const Color orange = Color(0xFFF9813A);

  // 회색 계열
  static const Color background = Color(0xFFFFFFFF);
  static const Color verylightGray = Color(0xFFF3F3F3); // 제일 연한 회색
  static const Color lightGray = Color(0xFFD9D9D9); // 연한 회색
  static const Color mediumGray = Color(0xFFB7B7B7); // 중간 회색
  static const Color darkGray = Color(0xFF434343); // 진한 회색

// 공지사항 메모 색상
static const Color noticeMemoYellow = Color(0xFFFFFDE7); // Colors.yellow.shade100 
static const Color noticeMemoRed = Color(0xFFFCE4EC);    // Colors.pink.shade100
static const Color noticeMemoBlue = Color(0xFFE3F2FD);   // Colors.blue.shade100
static const Color noticeMemoGreen = Color(0xFFE8F5E9);  // Colors.green.shade100
static const Color noticeMemoOrange = Color(0xFFFFF3E0); // Colors.orange.shade100
static const Color noticeMemoViolet = Color(0xFFF3E5F5); // Colors.purple.shade100
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
    ),
    textTheme: TextTheme(bodyMedium: _baseTextStyle),
  );
}
