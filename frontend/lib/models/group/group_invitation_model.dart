class GroupInvitation {
  final String adminComment;

  GroupInvitation({
    this.adminComment = '',
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      adminComment: json['adminComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminComment': adminComment,
    };
  }
}