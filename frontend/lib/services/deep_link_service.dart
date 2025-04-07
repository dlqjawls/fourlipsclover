import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _isInitialized = false;
  
  DeepLinkService._internal();
  
  // URL 변환 함수: 백엔드 URL을 앱 딥링크로 변환
  String convertToAppLink(String backendUrl) {
    try {
      Uri uri = Uri.parse(backendUrl);
      List<String> pathSegments = uri.pathSegments;
      
      // 마지막 세그먼트가 토큰인 경우
      if (pathSegments.isNotEmpty) {
        String token = pathSegments.last;
        return 'clover://invitation/$token';
      }
      return backendUrl;
    } catch (e) {
      debugPrint('URL 변환 중 오류: $e');
      return backendUrl;
    }
  }
  
  // 딥링크 리스너 초기화
  Future<void> initDeepLinks(BuildContext context) async {
    if (_isInitialized) return;
    
    try {
      // 앱이 처음 시작될 때 링크 확인
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleLink(context, initialUri);
      }
      
      // 앱이 이미 실행 중일 때 링크 수신
      _subscription = _appLinks.uriLinkStream.listen((uri) {
        debugPrint('딥링크 수신: $uri');
        _handleLink(context, uri);
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('딥링크 초기화 오류: $e');
    }
  }
  
  // 링크 처리 로직
  Future<void> _handleLink(BuildContext context, Uri uri) async {
    debugPrint('딥링크 처리: $uri');
    
    String? token;
    
    // 1. clover://invitation/{token} 형식 처리
    if (uri.scheme == 'clover' && uri.host == 'invitation') {
      if (uri.pathSegments.isNotEmpty) {
        token = uri.pathSegments.first;
      }
    }
    // 2. kakao{앱키}://kakaolink 형식 처리
    else if (uri.host == 'kakaolink' || uri.host == 'kakolink') {
      // 쿼리 파라미터에서 토큰 추출 시도
      if (uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token'];
      } 
      // execParams에서 토큰 추출 시도
      else if (uri.fragment.isNotEmpty) {
        final params = _parseExecParams(uri.fragment);
        token = params['token'];
      }
      // 쿼리스트링에서 토큰 추출 시도
      else if (uri.query.isNotEmpty) {
        final params = _parseExecParams(uri.query);
        token = params['token'];
      }
    }
    
    if (token != null && token.isNotEmpty) {
      debugPrint('토큰 추출 성공: $token');
      await _storePendingInvitation(token);
      _navigateToGroupScreen(context, token);
    } else {
      debugPrint('토큰을 찾을 수 없음: $uri');
    }
  }
  
  // execParams 파싱 헬퍼 함수
  Map<String, String> _parseExecParams(String paramsString) {
    Map<String, String> result = {};
    
    try {
      final pairs = paramsString.split('&');
      for (var pair in pairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0];
          final value = Uri.decodeComponent(keyValue[1]);
          result[key] = value;
        }
      }
    } catch (e) {
      debugPrint('execParams 파싱 오류: $e');
    }
    
    return result;
  }
  
  // 초대 토큰 저장
  Future<void> _storePendingInvitation(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pendingInvitationToken', token);
      debugPrint('초대 토큰 저장됨: $token');
    } catch (e) {
      debugPrint('초대 토큰 저장 중 오류: $e');
    }
  }
  
  // 적절한 화면으로 이동
void _navigateToGroupScreen(BuildContext context, String token) {
  debugPrint('그룹 초대 화면으로 이동: token=$token');
  
  // 직접 그룹 초대 화면으로 이동
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context).pushNamed(
      '/group/invitation',
      arguments: {'token': token}
    );
  });
}
  
  // 웹 URL에서 토큰 추출
  String? extractTokenFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // API 경로에서 토큰 추출
      if (pathSegments.contains('join-request') || 
          pathSegments.contains('invitation')) {
        return pathSegments.last;
      }
      
      return null;
    } catch (e) {
      debugPrint('URL에서 토큰 추출 오류: $e');
      return null;
    }
  }
  
  // 리소스 정리
  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
  }
}