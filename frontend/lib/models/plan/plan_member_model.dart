import 'package:flutter/foundation.dart';

class PlanMemberId {
  final int planId;
  final int memberId;

  PlanMemberId({
    required this.planId,
    required this.memberId,
  });

  factory PlanMemberId.fromJson(Map<String, dynamic> json) {
    return PlanMemberId(
      planId: json['planId'],
      memberId: json['memberId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'memberId': memberId,
    };
  }
}

class PlanMember {
  final PlanMemberId id;
  final String role;
  final DateTime joinedAt;

  PlanMember({
    required this.id,
    required this.role,
    required this.joinedAt,
  });

  factory PlanMember.fromJson(Map<String, dynamic> json) {
    return PlanMember(
      id: PlanMemberId.fromJson(json['id']),
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  // 새 PlanMember 객체 생성 (총무 또는 일반 회원)
  static PlanMember create({
    required int planId,
    required int memberId,
    required bool isTreasurer,
  }) {
    return PlanMember(
      id: PlanMemberId(
        planId: planId,
        memberId: memberId,
      ),
      role: isTreasurer ? '총무' : '회원',
      joinedAt: DateTime.now(),
    );
  }
}