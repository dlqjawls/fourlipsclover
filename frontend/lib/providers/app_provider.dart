import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService;
  final UserProvider _userProvider;
  late SharedPreferences _storage;

  AppProvider({required UserProvider userProvider})
    : _userProvider = userProvider,
      _userService = UserService(userProvider: userProvider) {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  bool _isLoggedIn = false;
  User? _user;
  String? _jwtToken;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get jwtToken => _jwtToken;

  // 초기 상태 로드
  Future<void> initializeApp() async {
    try {
      debugPrint('앱 초기화 시작');
      // 자동 로그인 시도
      debugPrint('자동 로그인 시도');
      final isAutoLoginSuccess = await _authService.tryAutoLogin();
      debugPrint('자동 로그인 결과: $isAutoLoginSuccess');

      if (isAutoLoginSuccess) {
        _isLoggedIn = true;
        debugPrint('자동 로그인 성공 - 사용자 정보 로드 시작');
        // 사용자 정보 로드
        await _userService.getUserProfile();
        debugPrint('자동 로그인 성공 - 사용자 정보 로드 완료');
      } else {
        debugPrint('자동 로그인 실패 - 로그인 상태 초기화');
        _isLoggedIn = false;
        _user = null;
        _jwtToken = null;
      }

      notifyListeners();
      debugPrint('앱 초기화 완료');
    } catch (e) {
      debugPrint('앱 초기화 실패: $e');
      _isLoggedIn = false;
      _user = null;
      _jwtToken = null;
      notifyListeners();
    }
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

  // 카카오 웹 로그인 (직접 호출용)
  Future<void> kakaoWebLogin() async {
    try {
      debugPrint('앱 프로바이더에서 카카오 웹 로그인 시도');
      final result = await _authService.kakaoWebLogin();

      _jwtToken = result['jwtToken'];
      _user = result['user'];
      _isLoggedIn = true;

      await _authService.saveLoginState(_isLoggedIn, _jwtToken);

      // 로그인 성공 후 사용자 정보 가져오기
      await _userService.getUserProfile();

      notifyListeners();
      debugPrint('앱 프로바이더에서 카카오 웹 로그인 성공');
    } catch (error) {
      debugPrint('앱 프로바이더에서 카카오 웹 로그인 실패: $error');
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
      // 카카오 SDK 로그아웃
      await UserApi.instance.logout();
      debugPrint('카카오 SDK 로그아웃 완료');

      // 앱 상태 초기화
      _isLoggedIn = false;
      _user = null;
      _jwtToken = null;

      // 사용자 정보 초기화
      _userProvider.clearUserProfile();

      // 로그인 상태 저장
      await _authService.saveLoginState(false, null);
      notifyListeners();
      debugPrint('앱 로그아웃 완료');
    } catch (error) {
      debugPrint('로그아웃 실패: $error');
      throw error;
    }
  }
}
