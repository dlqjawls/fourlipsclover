import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart'; // 테마 import 추가

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      await context.read<AppProvider>().kakaoLogin();
      if (mounted) {
        AppRoutes.navigateTo(context, '/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인에 실패했습니다')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 250, height: 250),
              const SizedBox(height: 50),
              const Text(
                '네입클로버',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '입안에 행운을 담다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 50),
              Container(
                width: 300,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleKakaoLogin(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/kakao_symbol.png',
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '카카오로 시작하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 여기부터 임시 홈 화면 이동 버튼
              const SizedBox(height: 20),
              Container(
                width: 300,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // 임시로 홈 화면으로 이동
                      AppRoutes.navigateTo(context, '/home');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Text(
                        '임시: 홈 화면으로 이동',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 여기까지 임시 홈 화면 이동 버튼

              const SizedBox(height: 20),

              // 여기부터 카카오페이 테스트 결제 버튼
              Container(
                width: 300,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.deepPurple, // 원하는 색으로 변경 가능
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AppRoutes.navigateTo(context, '/kakaopay_official'); //kakaopay_test
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Text(
                        '💳 카카오페이 테스트 결제',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 여기까지 카카오페이 테스트 결제 버튼
            ],
          ),
        ),
      ),
    );
  }
}
