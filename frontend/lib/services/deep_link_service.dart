import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

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
  void _handleLink(BuildContext context, Uri uri) {
    debugPrint('딥링크 처리: $uri');
    
    if (uri.host == 'invitation') {
      // clover://invitation/{token} 형식 처리
      if (uri.pathSegments.isNotEmpty) {
        final token = uri.pathSegments.first;
        _navigateToInvitationScreen(context, token);
      }
    }
  }
  
  // 초대 화면으로 이동
  void _navigateToInvitationScreen(BuildContext context, String token) {
    debugPrint('초대 토큰 처리: $token');
    // 메인 context에서 네비게이션하기 위해 나중에 실행
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