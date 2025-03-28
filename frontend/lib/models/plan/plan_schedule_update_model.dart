import '../restaurant_model.dart';

class PlanScheduleUpdate {
  final RestaurantResponse restaurant;
  final String placeName;
  final String? notes;
  final DateTime visitAt;

  PlanScheduleUpdate({
    required this.restaurant,
    required this.placeName,
    this.notes,
    required this.visitAt,
  });

  factory PlanScheduleUpdate.fromJson(Map<String, dynamic> json) {
    return PlanScheduleUpdate(
      restaurant: RestaurantResponse.fromJson(json['restaurant']),
      placeName: json['placeName'],
      notes: json['notes'],
      visitAt: DateTime.parse(json['visitAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant.toJson(),
      'placeName': placeName,
      'notes': notes,
      'visitAt': visitAt.toIso8601String(),
    };
  }
}