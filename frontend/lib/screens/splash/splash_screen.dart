import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 지연 시간을 주어 로고가 보이도록 함
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      debugPrint('스플래시 화면에서 앱 초기화 시작');
      await appProvider.initializeApp();
      debugPrint('앱 초기화 완료, 로그인 상태: ${appProvider.isLoggedIn}');

      if (!mounted) return;

      // 초대 토큰 확인
      await _checkPendingInvitation(context);

      if (appProvider.isLoggedIn) {
        // 자동 로그인 성공 - 홈 화면으로 이동
        debugPrint('자동 로그인 성공 - 홈 화면으로 이동');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // 로그인 필요 - 온보딩 또는 로그인 화면으로 이동
        debugPrint('로그인 필요 - 온보딩/로그인 화면으로 이동');

        // SharedPreferences를 사용하여 온보딩 표시 여부 확인
        final prefs = await SharedPreferences.getInstance();
        final showOnboarding = prefs.getBool('showOnboarding') ?? true;

        if (showOnboarding) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      debugPrint('앱 초기화 실패: $e');
      // 오류 발생 시 로그인 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  // 저장된 초대 토큰 확인
  Future<void> _checkPendingInvitation(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pendingInvitationToken');
      debugPrint('저장된 초대 토큰 확인: $token');

      if (token != null && token.isNotEmpty) {
        // 사용자 로그인 상태 확인
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final isLoggedIn = appProvider.isLoggedIn;

        if (isLoggedIn) {
          // 로그인 상태인 경우에만 토큰 삭제 및 초대 화면으로 이동
          await prefs.remove('pendingInvitationToken');

          // 조금 지연 후 초대 화면으로 이동 (홈 화면 로딩 후)
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              debugPrint('초대 화면으로 이동: $token');
              Navigator.of(
                context,
              ).pushNamed('/group/invitation', arguments: {'token': token});
            }
          });
        }
      }
    } catch (e) {
      debugPrint('초대 토큰 확인 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지
            Image.asset('assets/images/logo.png', width: 250, height: 250),
            const SizedBox(height: 30),
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
            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ],
        ),
      ),
    );
  }
}
