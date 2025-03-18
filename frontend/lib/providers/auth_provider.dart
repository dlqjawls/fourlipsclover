import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ...existing code...

class AuthProvider with ChangeNotifier {
  bool _isAuthorized = false;

  // 게터
  bool get isAuthorized => _isAuthorized;

  // 인증 상태 변경
  void setAuthorized(bool value) {
    _isAuthorized = value;
    saveAuthState();
    notifyListeners();
  }

  // SharedPreferences에 인증 상태 저장
  Future<void> saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthorized', _isAuthorized);
    } catch (e) {
      print('인증 상태 저장 오류: $e');
    }
  }

  // SharedPreferences에서 인증 상태 불러오기
  Future<void> loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthorized = prefs.getBool('isAuthorized') ?? false;
      notifyListeners();
    } catch (e) {
      print('인증 상태 불러오기 오류: $e');
    }
  }

  // Provider 초기화 시 호출
  void initialize() {
    loadAuthState();
  }
}


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AuthProvider with ChangeNotifier {
//   bool _isAuthorized = false;
  
//   // 게터
//   bool get isAuthorized => _isAuthorized;
  
//   // 서버에서 인증 상태 확인 및 업데이트
//   Future<void> checkAuthorizationStatus() async {
//     try {
//       final response = await http.get(
//         Uri.parse('YOUR_API_ENDPOINT/user/status'),
//         headers: {
//           'Authorization': 'Bearer YOUR_JWT_TOKEN',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _isAuthorized = data['isAuthorized'] ?? false;
//         notifyListeners();
//       }
//     } catch (e) {
//       print('인증 상태 확인 오류: $e');
//     }
//   }

//   // 인증 상태 변경 (백엔드 연동)
//   Future<void> setAuthorized(bool value) async {
//     try {
//       final response = await http.post(
//         Uri.parse('YOUR_API_ENDPOINT/user/authorize'),
//         headers: {
//           'Authorization': 'Bearer YOUR_JWT_TOKEN',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'isAuthorized': value}),
//       );

//       if (response.statusCode == 200) {
//         _isAuthorized = value;
//         notifyListeners();
//       }
//     } catch (e) {
//       print('인증 상태 변경 오류: $e');
//     }
//   }

//   // 앱 시작시 호출
//   void initialize() {
//     checkAuthorizationStatus();
//   }
// }