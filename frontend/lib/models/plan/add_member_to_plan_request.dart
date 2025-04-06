// lib/models/plan/add_member_to_plan_request.dart
class AddMemberToPlanRequest {
  final int memberId;

  AddMemberToPlanRequest({
    required this.memberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
    };
  }
}