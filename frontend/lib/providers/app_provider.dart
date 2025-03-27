import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'user_provider.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService;
  final UserProvider _userProvider;

  AppProvider({required UserProvider userProvider})
    : _userProvider = userProvider,
      _userService = UserService(userProvider: userProvider);

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

    // 로그인 상태라면 사용자 정보 로드
    if (_isLoggedIn) {
      try {
        await _userService.getUserProfile();
      } catch (e) {
        print('초기 사용자 정보 로드 실패: $e');
      }
    }

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

      // 로그인 성공 후 사용자 정보 가져오기
      await _userService.getUserProfile();

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

      // 사용자 정보 초기화
      _userProvider.clearUserProfile();

      await _authService.saveLoginState(false, null);
      notifyListeners();
    } catch (error) {
      debugPrint('로그아웃 실패: $error');
      throw error;
    }
  }
}
