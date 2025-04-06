// lib/models/plan/add_member_to_plan_response.dart
import './added_member_info.dart';

class AddMemberToPlanResponse {
  final List<AddedMemberInfo> addedMembers;

  AddMemberToPlanResponse({
    required this.addedMembers,
  });

  factory AddMemberToPlanResponse.fromJson(Map<String, dynamic> json) {
    return AddMemberToPlanResponse(
      addedMembers: (json['addedMembers'] as List)
          .map((member) => AddedMemberInfo.fromJson(member))
          .toList(),
    );
  }
}