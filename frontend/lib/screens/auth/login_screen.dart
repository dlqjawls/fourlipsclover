import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart'; // 테마 import 추가
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      debugPrint('카카오 로그인 시작');
      final appProvider = context.read<AppProvider>();

      // 웹 로그인 바로 시도 (앱 로그인 건너뛰기)
      try {
        debugPrint('카카오 웹 로그인 직접 시도');
        await appProvider.kakaoWebLogin();
        debugPrint('카카오 웹 로그인 성공');
      } catch (e) {
        debugPrint('카카오 웹 로그인 실패: $e');
        // 다른 오류는 그대로 전파
        rethrow;
      }

      // UserProvider에서 프로필 정보 설정
      final userProvider = context.read<UserProvider>();
      final userService = UserService(userProvider: userProvider);

      try {
        final userProfile = await userService.getUserProfile();
        debugPrint('서버에서 사용자 프로필 가져오기 성공: ${userProfile.toJson()}');
      } catch (e) {
        debugPrint('서버에서 사용자 프로필 가져오기 실패: $e');
        // 임시 프로필 생성
        if (appProvider.user != null) {
          final kakaoUser = appProvider.user!;
          final tempProfile = UserProfile(
            memberId: 0,
            email: kakaoUser.kakaoAccount?.email ?? '',
            nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? '',
            profileUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            createdAt: DateTime.now(),
            trustScore: 0.0,
            reviewCount: 0,
            groupCount: 0,
            recentPayments: [],
            planResponses: [],
            localAuth: false,
            localRank: '',
            localRegion: '',
            badgeName: '',
            tags: [],
          );
          userProvider.setUserProfile(tempProfile);
          debugPrint('임시 프로필 설정 완료: ${userProvider.userProfile?.toJson()}');
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error, stackTrace) {
      debugPrint('로그인 오류: $error');
      debugPrint('스택 트레이스: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인에 실패했습니다: ${error.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
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
                      Navigator.pushReplacementNamed(context, '/home');
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
                      Navigator.pushReplacementNamed(
                        context,
                        '/kakaopay_official',
                      ); //kakaopay_test
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
