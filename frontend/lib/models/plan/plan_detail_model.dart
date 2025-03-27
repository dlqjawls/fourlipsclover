import '../group/member_model.dart';

class PlanDetail {
  final int planId;
  final int groupId;
  final int treasurerId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final List<Member> members;

  PlanDetail({
    required this.planId,
    required this.groupId,
    required this.treasurerId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.members,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    return PlanDetail(
      planId: json['planId'],
      groupId: json['groupId'],
      treasurerId: json['treasurerId'],
      title: json['title'],
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      members: (json['members'] as List<dynamic>?)
          ?.map((memberJson) => Member.fromJson(memberJson))
          .toList() ?? [],
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
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}