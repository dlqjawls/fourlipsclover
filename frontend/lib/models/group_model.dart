class Group {
  final int groupId;
  final int memberId; // 그룹 생성자 ID
  final String name;
  final String description;
  final bool isPublic;
  final String createdAt;
  final String? updatedAt;
  final List<GroupMember> members;

  Group({
    required this.groupId,
    required this.memberId,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    this.updatedAt,
    this.members = const [],
  });

  // JSON으로부터 객체 생성
  factory Group.fromJson(Map<String, dynamic> json) {
    List<GroupMember> membersList = [];
    if (json.containsKey('members') && json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList();
    }

    return Group(
      groupId: json['groupId'],
      memberId: json['memberId'],
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      members: membersList,
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'memberId': memberId,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }

  // 수정된 그룹 정보 반환
  Group copyWith({
    int? groupId,
    int? memberId,
    String? name,
    String? description,
    bool? isPublic,
    String? createdAt,
    String? updatedAt,
    List<GroupMember>? members,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
    );
  }
}

class GroupMember {
  final int userId;
  final String nickname;
  final String role; // MANAGER, TREASURER, MEMBER 등의 역할

  GroupMember({
    required this.userId,
    required this.nickname,
    required this.role,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'],
      nickname: json['nickname'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'role': role,
    };
  }
}