class PlanCreateRequest {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> members;
  final int treasurerId;

  PlanCreateRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.members,
    required this.treasurerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0], 
      'members': members.map((id) => {'memberId': id}).toList(),
      'treasurerId': treasurerId,
    };
  }
}