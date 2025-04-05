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
    // 카카오톡 설치 여부 확인
    bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
    
    // 간단한 템플릿으로 변경 - 이미지 없이
    final template = FeedTemplate(
      content: Content(
        title: '$groupName 그룹 초대',
        description: description ?? '클로버 여행 그룹에 초대합니다!',
        link: Link(
          webUrl: Uri.parse(inviteUrl),
          mobileWebUrl: Uri.parse(inviteUrl),
        ),
      ),
    );

    // 카카오톡 공유하기
    if (isKakaoTalkSharingAvailable) {
      // URI 받고 실행
      Uri uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
      return true;
    } else {
      // 카카오톡이 설치되지 않은 경우
      Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(template: template);
      await launchBrowserTab(shareUrl);
      return true;
    }
  } catch (e) {
    print('카카오톡 공유 오류: $e');
    return false;
  }
}
}
