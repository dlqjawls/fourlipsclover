class Member {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl; // 백엔드 필드명에 맞춤
  String role; // role은 백엔드에서 오지 않지만 프론트엔드에서 계산

  Member({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
    this.role = '멤버', // 기본값 설정
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
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