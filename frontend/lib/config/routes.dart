import 'package:flutter/material.dart';
import 'package:frontend/screens/home/home_screen.dart';
// 여기에 화면 import 추가 예정
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/common/base_screen.dart';
import 'package:frontend/screens/user/user_screen.dart';
import 'package:frontend/screens/user/user_edit.dart';
import 'package:frontend/screens/user/user_profile.dart';
import 'package:frontend/screens/group/group_detail_screen.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:frontend/widgets/full_map_screen.dart';
import 'package:frontend/screens/payment/kakao_pay_screen.dart';
import 'package:flutter/material.dart';
import '../screens/payment/kakao_pay_official_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/journal': (context) => const BaseScreen(),
    '/ai_plan': (context) => const BaseScreen(),
    '/group': (context) => const BaseScreen(),
    '/login': (context) => const LoginScreen(),
    '/user': (context) => const UserScreen(),
    '/home': (context) => const BaseScreen(),
    '/user_edit': (context) => const UserEditScreen(),
    '/user_profile': (context) => const MyConsumptionPatternScreen(),

    '/kakaopay_test': (context) => KakaoPayScreen(),
    '/kakaopay_official': (context) => const KakaoPayOfficialScreen(),

    '/group_detail': (context) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final group = arguments['group'] as Group;
      return GroupDetailScreen(group: group);
    },

    '/full_map': (context) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final locationName = arguments['locationName'] as String;
      return FullMapScreen(locationName: locationName);
    },

    // 앱의 경로를 여기에 등록
    // 예시: '/': (context) => HomeScreen(),
    // 예시: '/login': (context) => LoginScreen(),
  };

  // 네비게이션 헬퍼 메서드
  // 사용법
  // Navigator.pushNamed(context, '/login', arguments: {'message': '로그인이 필요합니다'});
  // 이거대신
  // AppRoutes.navigateTo(context, '/login', arguments: {'message': '로그인이 필요합니다'});
  // static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
  //   Navigator.pushNamed(context, routeName, arguments: arguments);
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // 이전 화면으로 돌아가기
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
