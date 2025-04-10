import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';

class KakaoShareService {
  static Future<bool> shareGroupInvitation({
    required String groupName,
    required String inviteUrl,
    String? description,
  }) async {
    try {
      debugPrint('카카오톡 공유 시작: $groupName, $inviteUrl');
      
      // 카카오톡 설치 여부 확인
      bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
      debugPrint('카카오톡 설치 여부: $isKakaoTalkSharingAvailable');
      
      // 초대 URL에서 토큰 추출
      String? token;
      try {
        final uri = Uri.parse(inviteUrl);
        if (uri.pathSegments.isNotEmpty) {
          token = uri.pathSegments.last;
        }
        debugPrint('추출된 토큰: $token');
      } catch (e) {
        debugPrint('토큰 추출 오류: $e');
      }
      
      // 웹훅을 위한 서버 콜백 인자
      final serverCallbackArgs = {
        'groupName': groupName,
        'token': token ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      
      // 실행 파라미터 (앱에서 처리할 때 사용)
      final execParams = 'token=$token';
      
      // 커스텀 템플릿 ID 사용
      const templateId = 119412;
      
      // 템플릿 파라미터 설정
      final templateArgs = {
        'groupName': groupName,
        'description': description ?? '지금 바로 초대 링크로 참여하세요 🍀',
        'inviteUrl': inviteUrl,
        'execParams': execParams,
      };
      
      debugPrint('카카오톡 공유 파라미터: $templateArgs');
      
      if (isKakaoTalkSharingAvailable) {
        // 카카오톡이 설치된 경우 - 템플릿 ID로 공유
        try {
          debugPrint('커스텀 템플릿으로 공유 시도: $templateId');
          Uri uri = await ShareClient.instance.shareCustom(
            templateId: templateId, 
            templateArgs: templateArgs,
            serverCallbackArgs: serverCallbackArgs
          );
          debugPrint('카카오톡 공유 URI 생성됨: $uri');
          
          // launchKakaoTalk 실행 전 로그
          debugPrint('카카오톡 실행 시도');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('카카오톡 공유 성공');
          return true;
        } catch (e) {
          debugPrint('커스텀 템플릿 공유 실패, 기본 템플릿으로 대체: $e');
          debugPrint('스택 트레이스: ${StackTrace.current}');
          // 실패 시 기본 템플릿으로 대체
          return _shareFallbackTemplate(groupName, inviteUrl, description, token, serverCallbackArgs);
        }
      } else {
        // 카카오톡이 설치되지 않은 경우 - 웹 공유
        try {
          debugPrint('웹 공유 시도');
          Uri shareUrl = await WebSharerClient.instance.makeCustomUrl(
            templateId: templateId, 
            templateArgs: templateArgs
          );
          debugPrint('웹 공유 URL 생성됨: $shareUrl');
          await launchUrl(shareUrl, mode: LaunchMode.externalApplication);
          debugPrint('웹 공유 성공');
          return true;
        } catch (e) {
          debugPrint('웹 공유 실패: $e');
          debugPrint('스택 트레이스: ${StackTrace.current}');
          return false;
        }
      }
    } catch (e) {
      debugPrint('카카오톡 공유 오류: $e');
      debugPrint('스택 트레이스: ${StackTrace.current}');
      return false;
    }
  }
  
  // 기본 템플릿으로 대체 공유 (템플릿 ID가 잘못된 경우 등에 사용)
  static Future<bool> _shareFallbackTemplate(
    String groupName, 
    String inviteUrl, 
    String? description,
    String? token,
    Map<String, String> serverCallbackArgs
  ) async {
    try {
      debugPrint('기본 템플릿으로 공유 시도');
      
      // 실행 파라미터 설정
      final execParams = {'token': token ?? ''};
      
      final template = FeedTemplate(
        content: Content(
          title: '$groupName에서 우리 함께 여행 계획 짜고 추억 만들어요!',
          description: description ?? '지금 바로 초대 링크로 참여하세요 🍀',
          imageUrl: Uri.parse('https://fourlipsclover.duckdns.org/assets/img/logo.png'),
          link: Link(
            webUrl: Uri.parse(inviteUrl),
            mobileWebUrl: Uri.parse(inviteUrl),
            androidExecutionParams: execParams,
            iosExecutionParams: execParams,
          ),
        ),
        buttons: [
          Button(
            title: '초대 확인하기',
            link: Link(
              webUrl: Uri.parse(inviteUrl),
              mobileWebUrl: Uri.parse(inviteUrl),
              androidExecutionParams: execParams,
              iosExecutionParams: execParams,
            ),
          ),
        ],
      );
      
      debugPrint('기본 템플릿 설정 완료');
      Uri uri = await ShareClient.instance.shareDefault(
        template: template,
        serverCallbackArgs: serverCallbackArgs
      );
      debugPrint('기본 템플릿 URI 생성됨: $uri');
      
      debugPrint('기본 템플릿으로 카카오톡 실행 시도');
      await ShareClient.instance.launchKakaoTalk(uri);
      debugPrint('기본 템플릿 공유 성공');
      return true;
    } catch (e) {
      debugPrint('기본 템플릿 공유 오류: $e');
      debugPrint('스택 트레이스: ${StackTrace.current}');
      return false;
    }
  }
}