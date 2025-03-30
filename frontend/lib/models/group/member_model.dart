class Member {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl; 
  String role; 

  Member({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
    this.role = '멤버', 
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    // URL 처리 로직 추가
    String? profileUrl = json['profileUrl'];
    if (profileUrl != null && profileUrl.contains('%')) {
      try {
        // 중복 경로 제거 및 URL 정리
        if (profileUrl.contains('http%3A') ||
            profileUrl.contains('/mypage/http')) {
          // 기본 이미지로 대체
          profileUrl = null;
        }
      } catch (e) {
        profileUrl = null;
      }
    }

    return Member(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: profileUrl,
      // role은 백엔드에서 오지 않으므로 기본값 '멤버' 사용
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'email': email,
      'nickname': nickname,
      'profileUrl': profileUrl,
      // role은 백엔드로 보내지 않음
    };
  }
}
