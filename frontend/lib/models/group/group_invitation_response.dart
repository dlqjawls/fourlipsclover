class GroupInvitationResponse {
  final String adminComment;

  GroupInvitationResponse({
    this.adminComment = '',
  });

  factory GroupInvitationResponse.fromJson(Map<String, dynamic> json) {
    return GroupInvitationResponse(
      adminComment: json['adminComment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminComment': adminComment,
    };
  }
}