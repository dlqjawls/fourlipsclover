import 'package:flutter/material.dart';
// 여기에 화면 import 추가 예정

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // 앱의 경로를 여기에 등록
    // 예시: '/': (context) => HomeScreen(),
    // 예시: '/login': (context) => LoginScreen(),
  };
  
  // 네비게이션 헬퍼 메서드
  // 사용법 
  // Navigator.pushNamed(context, '/login', arguments: {'message': '로그인이 필요합니다'});
  // 이거대신
  // AppRoutes.navigateTo(context, '/login', arguments: {'message': '로그인이 필요합니다'});
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  
  // 이전 화면으로 돌아가기
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}