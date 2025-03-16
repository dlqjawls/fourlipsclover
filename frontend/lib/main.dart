import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart'; // AppTheme 클래스 임포트
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/kakao_service.dart';
import 'screens/common/base_screen.dart';
import 'providers/search_provider.dart';

void main() async {
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
        ChangeNotifierProvider(create: (_) => SearchProvider()), // 추가
      ],
      child: MaterialApp(
        title: '네입클로버',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
