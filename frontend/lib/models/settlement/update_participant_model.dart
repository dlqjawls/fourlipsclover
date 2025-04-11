// lib/models/settlement/update_participant_model.dart

class UpdateParticipantRequest {
  final List<int> memberId;

  UpdateParticipantRequest({required this.memberId});

  Map<String, dynamic> toJson() {
    return {'memberId': memberId};
  }
}

class UpdateParticipantResponse {
  final int expenseId;
  final List<ExpenseParticipantInfo> participants;

  UpdateParticipantResponse({
    required this.expenseId,
    required this.participants,
  });

  factory UpdateParticipantResponse.fromJson(Map<String, dynamic> json) {
    return UpdateParticipantResponse(
      expenseId: json['expenseId'],
      participants:
          (json['participants'] as List)
              .map(
                (participant) => ExpenseParticipantInfo.fromJson(participant),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'participants':
          participants
              .map(
                (p) => {
                  'expenseParticipantId': p.expenseParticipantId,
                  'memberId': p.memberId,
                  'email': p.email,
                  'nickname': p.nickname,
                  'profileUrl': p.profileUrl,
                },
              )
              .toList(),
    };
  }
}

class ExpenseParticipantInfo {
  final int expenseParticipantId;
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl;

  ExpenseParticipantInfo({
    required this.expenseParticipantId,
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
  });

  factory ExpenseParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipantInfo(
      expenseParticipantId: json['expenseParticipantId'],
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
    );
  }
}
