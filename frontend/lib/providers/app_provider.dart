import 'package:flutter/material.dart';

// ChangeNotifier를 상속받아 상태 변경을 알림
class AppProvider with ChangeNotifier {
  // 앱에서 관리할 상태 변수들 (밑줄로 시작하는 private 변수)
  bool _isLoggedIn = false;
  
  // 상태에 접근하기 위한 getter (외부에서 읽기만 가능)
  bool get isLoggedIn => _isLoggedIn;
  
  // 상태를 변경하는 메서드들
  // 상태 변경 후에는 반드시 notifyListeners()를 호출하여 UI에 변경 사항을 알림
  void login() {
    _isLoggedIn = true;
    notifyListeners(); // 이 Provider를 사용하는 모든 위젯에게 상태 변경을 알림
  }
  
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
  
  // Provider 사용 예시:
  // 1. main.dart에서 ChangeNotifierProvider로 등록
  // ChangeNotifierProvider(
  //   create: (context) => AppProvider(),
  //   child: MaterialApp(...),
  // )
  
  // 2. 위젯에서 Provider 상태 읽기
  // final provider = Provider.of<AppProvider>(context);
  // Text('로그인 상태: ${provider.isLoggedIn}');
  
  // 3. 위젯에서 Provider 메서드 호출하기
  // ElevatedButton(
  //   onPressed: () => Provider.of<AppProvider>(context, listen: false).login(),
  //   child: Text('로그인'),
  // )
}