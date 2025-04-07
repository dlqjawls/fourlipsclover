import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    // 온보딩 완료 상태 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "원하는 시간에 만나보세요",
          body: "여행 일정을 자유롭게 조율할 수 있어요",
          image: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/그룹.png', fit: BoxFit.contain),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24.0,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16.0,
              color: AppColors.mediumGray,
            ),
            pageColor: Colors.white,
            imagePadding: const EdgeInsets.only(top: 60),
            titlePadding: const EdgeInsets.only(top: 30),
            bodyPadding: EdgeInsets.zero,
            imageFlex: 3,
            bodyFlex: 1,
          ),
        ),
        PageViewModel(
          title: "믿을 수 있는 현지 가이드",
          body: "검증된 가이드와 함께하는 특별한 여행",
          image: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/매칭.png', fit: BoxFit.contain),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24.0,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16.0,
              color: AppColors.mediumGray,
            ),
            pageColor: Colors.white,
            imagePadding: const EdgeInsets.only(top: 60),
            titlePadding: const EdgeInsets.only(top: 30),
            bodyPadding: EdgeInsets.zero,
            imageFlex: 3,
            bodyFlex: 1,
          ),
        ),
        PageViewModel(
          title: "근처 맛집 찾기",
          body: "내 주변의 믿을 수 있는 맛집를 만나보세요",
          image: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/지도.png', fit: BoxFit.contain),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24.0,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16.0,
              color: AppColors.mediumGray,
            ),
            pageColor: Colors.white,
            imagePadding: const EdgeInsets.only(top: 60),
            titlePadding: const EdgeInsets.only(top: 30),
            bodyPadding: EdgeInsets.zero,
            imageFlex: 3,
            bodyFlex: 1,
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: Text(
        '건너뛰기',
        style: TextStyle(color: AppColors.mediumGray, fontSize: 16),
      ),
      next: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.arrow_forward, color: AppColors.primary),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          '시작하기',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(8.0),
        activeSize: const Size(8.0, 8.0),
        activeColor: AppColors.primary,
        color: Colors.grey[300]!,
        spacing: const EdgeInsets.symmetric(horizontal: 4.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
