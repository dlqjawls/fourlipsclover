import './member_model.dart';

class GroupJoinRequest {
  final int id;
  final int groupId;
  final int memberId;
  final Member member;  // 가입 요청한 회원 (백엔드에서 변환 필요)
  final String status;
  final DateTime requestedAt;
  final String? adminComment;
  final DateTime? updatedAt;
  final String token;
  
  GroupJoinRequest({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.member,
    required this.status,
    required this.requestedAt,
    this.adminComment,
    this.updatedAt,
    required this.token,
  });

  factory GroupJoinRequest.fromJson(Map<String, dynamic> json) {
    return GroupJoinRequest(
      id: json['id'],
      groupId: json['group']['id'],  // 중첩된 객체에서 id 추출
      memberId: json['member']['memberId'],  // 중첩된 객체에서 id 추출
      member: Member.fromJson(json['member']),
      status: json['status'],
      requestedAt: DateTime.parse(json['requestedAt']),
      adminComment: json['adminComment'],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'memberId': memberId,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'adminComment': adminComment,
      'updatedAt': updatedAt?.toIso8601String(),
      'token': token,
    };
  }
}