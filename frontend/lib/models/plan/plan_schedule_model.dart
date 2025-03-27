class PlanSchedule {
  final int planScheduleId;
  final String placeName;
  final String? notes;
  final DateTime visitAt;

  PlanSchedule({
    required this.planScheduleId,
    required this.placeName,
    this.notes,
    required this.visitAt,
  });

  factory PlanSchedule.fromJson(Map<String, dynamic> json) {
    return PlanSchedule(
      planScheduleId: json['planScheduleId'],
      placeName: json['placeName'],
      notes: json['notes'],
      visitAt: DateTime.parse(json['visitAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planScheduleId': planScheduleId,
      'placeName': placeName,
      'notes': notes,
      'visitAt': visitAt.toIso8601String(),
    };
  }

  // 수정된 일정 정보 반환
  PlanSchedule copyWith({
    int? planScheduleId,
    String? placeName,
    String? notes,
    DateTime? visitAt,
  }) {
    return PlanSchedule(
      planScheduleId: planScheduleId ?? this.planScheduleId,
      placeName: placeName ?? this.placeName,
      notes: notes ?? this.notes,
      visitAt: visitAt ?? this.visitAt,
    );
  }
}