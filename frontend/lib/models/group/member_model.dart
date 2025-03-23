class Member {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileImage;
  final String role; // '그룹장', '총무', '멤버' 등의 역할 정보 추가

  Member({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileImage,
    this.role = '멤버', // 기본값 설정
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      role: json['role'] ?? '멤버', // 백엔드에서 role 정보가 없을 경우 기본값
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'email': email,
      'nickname': nickname,
      'profileImage': profileImage,
      'role': role,
    };
  }
}