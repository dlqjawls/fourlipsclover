import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../services/auth_service.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  User? _user;
  String? _jwtToken;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get jwtToken => _jwtToken;

  // 초기 상태 로드
  Future<void> initializeApp() async {
    final loginState = await _authService.loadLoginState();
    _isLoggedIn = loginState['isLoggedIn'];
    _jwtToken = loginState['jwtToken'];
    notifyListeners();
  }

  // 카카오 로그인
  Future<void> kakaoLogin() async {
    try {
      final result = await _authService.kakaoLogin();

      _jwtToken = result['jwtToken'];
      _user = result['user'];
      _isLoggedIn = true;

      await _authService.saveLoginState(_isLoggedIn, _jwtToken);
      notifyListeners();
    } catch (error) {
      _isLoggedIn = false;
      _user = null;
      _jwtToken = null;
      notifyListeners();
      throw error;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _authService.logout();

      _isLoggedIn = false;
      _user = null;
      _jwtToken = null;

      await _authService.saveLoginState(false, null);
      notifyListeners();
    } catch (error) {
      debugPrint('로그아웃 실패: $error');
      throw error;
    }
  }
}
