import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/kakao_service.dart';
import 'screens/common/base_screen.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: '네입클로버',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFEE500)),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        //home: const LoginScreen(), // home 속성 추가
        home: const BaseScreen(), // home 속성 추가
        routes: AppRoutes.routes,
      ),
    );
  }
}
