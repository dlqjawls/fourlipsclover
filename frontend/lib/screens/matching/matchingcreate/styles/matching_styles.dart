import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class MatchingStyles {
  // AppBar 스타일
  static PreferredSize buildAppBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  // 진행 표시줄 스타일
  static Widget buildProgressIndicator(double value) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    );
  }

  // 메인 제목 스타일
  static const titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGray,
  );

  // 부제목 스타일
  static const subtitleStyle = TextStyle(
    fontSize: 16,
    color: AppColors.mediumGray,
  );

  // 버튼 스타일
  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    minimumSize: Size(double.infinity, 55),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );

  // 버튼 텍스트 스타일
  static const buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 공통 패딩
  static const defaultPadding = EdgeInsets.all(20.0);

  // 선택된 아이템 그림자
  static List<BoxShadow> selectedShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const dialogTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.darkGray,
    fontSize: 18,
  );

  static const dialogContentStyle = TextStyle(
    fontSize: 16,
    color: AppColors.darkGray,
  );

  static const dialogContentBoldStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGray,
  );

  static final dialogButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static const dialogButtonTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // 카드 스타일
  static final cardStyle = CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );
}
