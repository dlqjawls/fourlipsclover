class GroupInvitation {
  final int id;
  final int groupId;
  final String token;
  final DateTime createdAt;
  final DateTime expiredAt;
  final DateTime? updatedAt;
  
  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.token,
    required this.createdAt,
    required this.expiredAt,
    this.updatedAt,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      id: json['id'],
      groupId: json['groupId'],
      token: json['token'],
      createdAt: DateTime.parse(json['createdAt']),
      expiredAt: DateTime.parse(json['expiredAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'expiredAt': expiredAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}