// lib/models/plan/added_member_info.dart
class AddedMemberInfo {
  final int memberId;
  final String nickname;

  AddedMemberInfo({
    required this.memberId,
    required this.nickname,
  });

  factory AddedMemberInfo.fromJson(Map<String, dynamic> json) {
    return AddedMemberInfo(
      memberId: json['memberId'],
      nickname: json['nickname'],
    );
  }
}