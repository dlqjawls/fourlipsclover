import './member_model.dart';

class GroupJoinRequest {
  final int id;
  final int groupId;
  final int memberId;
  final Member member; // 가입 요청한 회원 (백엔드에서 변환 필요)
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
    // 상태 값 처리
    String statusValue = 'PENDING'; // 기본값

    // json['status']가 존재하면 사용
    if (json['status'] != null) {
      statusValue = json['status'];
    }

    return GroupJoinRequest(
      id: json['id'],
      groupId: json['group'] != null ? json['group']['id'] : 0,
      memberId: json['member'] != null ? json['member']['memberId'] : 0,
      member:
          json['member'] != null
              ? Member.fromJson(json['member'])
              : Member(memberId: 0, email: '', nickname: '알 수 없음'),
      status: statusValue,
      requestedAt: DateTime.parse(
        json['requestedAt'] ?? DateTime.now().toIso8601String(),
      ),
      adminComment: json['adminComment'],
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      token: json['token'] ?? '',
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
