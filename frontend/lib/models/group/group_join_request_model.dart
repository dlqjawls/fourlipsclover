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
    // 데이터 구조 로깅

    try {
      return GroupJoinRequest(
        id: json['id'] ?? 0,
        groupId: json['group'] != null ? json['group']['groupId'] ?? 0 : 0,
        memberId: json['member'] != null ? json['member']['memberId'] ?? 0 : 0,
        member:
            json['member'] != null
                ? Member.fromJson(json['member'])
                : Member(memberId: 0, email: '', nickname: '알 수 없음'),
        status: json['status'] ?? 'PENDING',
        requestedAt: DateTime.parse(
          json['requestedAt'] ?? DateTime.now().toIso8601String(),
        ),
        adminComment: json['adminComment'],
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'])
                : null,
        token: json['token'] ?? '',
      );
    } catch (e) {
      // 파싱 오류 시 기본 객체 반환
      return GroupJoinRequest(
        id: 0,
        groupId: 0,
        memberId: 0,
        member: Member(memberId: 0, email: '', nickname: '알 수 없음'),
        status: 'PENDING',
        requestedAt: DateTime.now(),
        token: '',
      );
    }
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
