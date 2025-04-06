// lib/models/plan/edit_treasurer_request.dart
class EditTreasurerRequest {
  final int newTreasurerId;

  EditTreasurerRequest({
    required this.newTreasurerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'newTreasurerId': newTreasurerId,
    };
  }
}