import './member_model.dart';

class GroupDetail {
  final int groupId;
  final String name;
  final String description;
  final bool isPublic;
  final List<Member> members;

  GroupDetail({
    required this.groupId,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.members,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      groupId: json['groupId'],
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'],
      members: (json['members'] as List<dynamic>)
          .map((memberJson) => Member.fromJson(memberJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}