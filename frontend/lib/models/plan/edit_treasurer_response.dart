// lib/models/plan/edit_treasurer_response.dart
class EditTreasurerResponse {
  final int planId;
  final int oldTreasurerId;
  final String oldTreasurerNickname;
  final int newTreasurerId;
  final String newTreasurerNickname;

  EditTreasurerResponse({
    required this.planId,
    required this.oldTreasurerId,
    required this.oldTreasurerNickname,
    required this.newTreasurerId,
    required this.newTreasurerNickname,
  });

  factory EditTreasurerResponse.fromJson(Map<String, dynamic> json) {
    return EditTreasurerResponse(
      planId: json['planId'],
      oldTreasurerId: json['oldTreasurerId'],
      oldTreasurerNickname: json['oldTreasurerNickname'],
      newTreasurerId: json['newTreasurerId'],
      newTreasurerNickname: json['newTreasurerNickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'oldTreasurerId': oldTreasurerId,
      'oldTreasurerNickname': oldTreasurerNickname,
      'newTreasurerId': newTreasurerId,
      'newTreasurerNickname': newTreasurerNickname,
    };
  }
}