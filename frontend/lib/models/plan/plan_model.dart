class Plan {
  final int planId;
  final int groupId;
  final int treasurerId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<int> memberIds;

  Plan({
    required this.planId,
    required this.groupId,
    required this.treasurerId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    required this.memberIds,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      planId: json['planId'],
      groupId: json['groupId'],
      treasurerId: json['treasurerId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      memberIds: json['memberIds'] != null 
          ? List<int>.from(json['memberIds']) 
          : [],
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
      'memberIds': memberIds,
    };
  }

  // 수정된 계획 정보 반환
  Plan copyWith({
    int? planId,
    int? groupId,
    int? treasurerId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? memberIds,
  }) {
    return Plan(
      planId: planId ?? this.planId,
      groupId: groupId ?? this.groupId,
      treasurerId: treasurerId ?? this.treasurerId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}