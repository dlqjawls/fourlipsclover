import './member_model.dart';

class GroupJoinRequest {
  final int requestId;
  final int groupId;
  final int applicantId;
  final Member applicant;
  final String status;
  final DateTime requestedAt;
  
  GroupJoinRequest({
    required this.requestId,
    required this.groupId,
    required this.applicantId,
    required this.applicant,
    required this.status,
    required this.requestedAt,
  });

  factory GroupJoinRequest.fromJson(Map<String, dynamic> json) {
    return GroupJoinRequest(
      requestId: json['requestId'],
      groupId: json['groupId'],
      applicantId: json['applicantId'],
      applicant: Member.fromJson(json['applicant']),
      status: json['status'],
      requestedAt: DateTime.parse(json['requestedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'groupId': groupId,
      'applicantId': applicantId,
      'applicant': applicant.toJson(),
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }
}