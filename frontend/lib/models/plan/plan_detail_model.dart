// plan_detail_model.dart 파일

import 'package:flutter/foundation.dart';
import '../group/member_model.dart'; // Member 클래스가 정의된 파일 임포트

class PlanDetail {
  final int planId;
  final int groupId;
  final int treasurerId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Member> members; // Member 객체 리스트 추가

  PlanDetail({
    required this.planId,
    required this.groupId,
    required this.treasurerId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    required this.members, // 생성자에 members 파라미터 추가
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    // members 필드 파싱
    List<Member> membersList = [];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => Member.fromJson(member))
          .toList();
      
      // role 설정 (총무 또는 회원)
      final treasurerId = json['treasurerId'];
      for (var member in membersList) {
        member.role = member.memberId == treasurerId ? '총무' : '회원';
      }
    }

    return PlanDetail(
      planId: json['planId'],
      groupId: json['groupId'],
      treasurerId: json['treasurerId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      members: membersList, // 파싱된 멤버 리스트 전달
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'groupId': groupId,
      'treasurerId': treasurerId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(), // 멤버 객체를 JSON으로 변환
    };
  }

  // 수정된 계획 상세 정보 반환
  PlanDetail copyWith({
    int? planId,
    int? groupId,
    int? treasurerId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Member>? members,
  }) {
    return PlanDetail(
      planId: planId ?? this.planId,
      groupId: groupId ?? this.groupId,
      treasurerId: treasurerId ?? this.treasurerId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
    );
  }
}