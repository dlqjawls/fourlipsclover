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
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (context) => MapProvider()),
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