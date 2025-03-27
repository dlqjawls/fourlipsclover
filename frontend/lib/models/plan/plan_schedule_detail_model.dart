import '../restaurant_model.dart';

class PlanScheduleDetail {
  final int planId;
  final int planScheduleId;
  final String? notes;
  final DateTime visitAt;
  final DateTime updatedAt;
  final RestaurantResponse restaurant;

  PlanScheduleDetail({
    required this.planId,
    required this.planScheduleId,
    this.notes,
    required this.visitAt,
    required this.updatedAt,
    required this.restaurant,
  });

  factory PlanScheduleDetail.fromJson(Map<String, dynamic> json) {
    return PlanScheduleDetail(
      planId: json['planId'],
      planScheduleId: json['planScheduleId'],
      notes: json['notes'],
      visitAt: DateTime.parse(json['visitAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      restaurant: RestaurantResponse.fromJson(json['restaurant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planScheduleId': planScheduleId,
      'notes': notes,
      'visitAt': visitAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'restaurant': restaurant.toJson(),
    };
  }
}