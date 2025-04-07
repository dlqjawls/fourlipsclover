import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/kakao_service.dart';
import 'providers/search_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/kakao_map_service.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/map_provider.dart';
import 'providers/user_provider.dart';
import 'providers/settlement_provider.dart';
import 'providers/notice_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/services/user_service.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'providers/matching_provider.dart';
import 'services/deep_link_service.dart';
import 'providers/review_provider.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    final kakaoAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
    KakaoSdk.init(nativeAppKey: kakaoAppKey);
    print('카카오 SDK 초기화 성공: $kakaoAppKey');
  } catch (e) {
    print('카카오 SDK 초기화 실패: $e');
  }

  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 딥링크 서비스 초기화를 위한 딜레이 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('딥링크 서비스 초기화 시작');
      // 네비게이터 키의 현재 컨텍스트를 사용하여 딥링크 서비스 초기화
      if (_navigatorKey.currentContext != null) {
        DeepLinkService().initDeepLinks(_navigatorKey.currentContext!);
        print('딥링크 서비스 초기화 완료');
      } else {
        print('딥링크 서비스 초기화 실패: 컨텍스트가 없음');
      }

      _checkOnboarding();
    });
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;
    setState(() {
      _showOnboarding = showOnboarding;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 딥링크 서비스 정리
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 백그라운드에서 돌아올 때 안전하게 Provider에 접근
      final context = _navigatorKey.currentContext;
      if (context != null) {
        try {
          final appProvider = Provider.of<AppProvider>(context, listen: false);
          appProvider.initializeApp();
        } catch (e) {
          print('앱 프로바이더 접근 오류: $e');
        }

        // 앱이 재개될 때 딥링크 서비스 확인
        DeepLinkService().initDeepLinks(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(
          create:
              (context) =>
                  UserService(userProvider: context.read<UserProvider>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => AppProvider(
                userProvider: Provider.of<UserProvider>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => SettlementProvider()),
        ChangeNotifierProvider(create: (context) => MapProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: '네입클로버',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: _navigatorKey, // 네비게이터 키 추가
        home: Builder(
          builder: (context) {
            // 홈 화면에서 저장된 초대 토큰 확인
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_showOnboarding) {
                // 온보딩 후 초대 토큰 확인
                _checkPendingInvitation(context);
              } else {
                // 로그인 화면에서 초대 토큰 확인
                _checkPendingInvitation(context);
              }
            });

            // 온보딩 화면과 로그인 화면 중 선택
            return _showOnboarding
                ? const OnboardingScreen()
                : const LoginScreen();
          },
        ),
        routes: AppRoutes.routes,
        // 로컬라이제이션 설정 추가
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'), // 한국어
          Locale('en', 'US'), // 영어
        ],
      ),
    );
  }

  // 저장된 초대 토큰 확인
  Future<void> _checkPendingInvitation(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pendingInvitationToken');
      print('저장된 초대 토큰 확인: $token');

      if (token != null && token.isNotEmpty) {
        // 토큰 사용 후 삭제
        await prefs.remove('pendingInvitationToken');

        // 조금 지연 후 초대 화면으로 이동 (로그인 화면 로딩 후)
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            print('초대 화면으로 이동: $token');
            Navigator.of(
              context,
            ).pushNamed('/group/invitation', arguments: {'token': token});
          }
        });
      }
    } catch (e) {
      print('초대 토큰 확인 중 오류: $e');
    }
  }
}
