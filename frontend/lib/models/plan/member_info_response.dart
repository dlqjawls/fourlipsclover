// lib/models/plan/member_info_response.dart
class MemberInfoResponse {
  final int memberId;
  final String nickname;
  final String email;

  MemberInfoResponse({
    required this.memberId,
    required this.nickname,
    required this.email,
  });

  factory MemberInfoResponse.fromJson(Map<String, dynamic> json) {
    return MemberInfoResponse(
      memberId: json['memberId'],
      nickname: json['nickname'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'nickname': nickname,
      'email': email,
    };
  }
}