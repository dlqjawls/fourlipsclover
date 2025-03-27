import 'dart:ffi';

class Group {
  final int groupId;
  final int memberId;
  final String name;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.groupId,
    required this.memberId,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'],
      memberId: json['memberId'],
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'memberId': memberId,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 수정된 그룹 정보 반환
  Group copyWith({
    int? groupId,
    int? memberId,
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
