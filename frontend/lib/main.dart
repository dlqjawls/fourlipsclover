import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart'; // AppTheme 클래스 임포트
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/kakao_service.dart';
import 'providers/search_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/kakao_map_service.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/map_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notice_provider.dart'; // 추가된 NoticeProvider
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/services/user_service.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'providers/matching_provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 백그라운드에서 돌아올 때 로그인 상태 확인
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.initializeApp();
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
        ChangeNotifierProvider(create: (context) => MapProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
      ],
      child: MaterialApp(
        title: '네입클로버',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
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
}
