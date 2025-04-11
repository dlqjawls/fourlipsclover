import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart'; // 테마 import 추가
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/toast_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _clearPreviousSession();
  }

  Future<void> _clearPreviousSession() async {
    try {
      // 카카오 SDK 세션 정리
      await UserApi.instance.logout();
      debugPrint('이전 카카오 세션 정리 완료');
    } catch (e) {
      debugPrint('세션 정리 중 오류: $e');
    }
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      debugPrint('카카오 로그인 시작');
      final appProvider = context.read<AppProvider>();

      // 카카오 로그인 시도
      await appProvider.kakaoLogin();
      debugPrint('카카오 로그인 성공');

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
    } catch (error) {
      debugPrint('로그인 오류: $error');

      if (mounted) {
        ToastBar.clover('로그인에 실패했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // 상단 텍스트
            const Text(
              '환영합니다!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 60),

            // 이미지 (왼쪽으로 치우치게)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Image.asset(
                    'assets/images/start.png',
                    width: 600,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 하단 텍스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '입안에 행운을 담을\n 준비되셨나요?',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Container(
                width: 340,
                height: 50,
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
            ),
          ],
        ),
      ),
    );
  }
}
