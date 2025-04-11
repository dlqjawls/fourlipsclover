class PlanScheduleUpdateRequest {
  final int? restaurantId;
  final String? kakaoPlaceId; // 카카오 Place ID 추가
  final String? notes;
  final DateTime visitAt;

  PlanScheduleUpdateRequest({
    this.restaurantId,
    this.kakaoPlaceId,
    this.notes,
    required this.visitAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'visitAt': visitAt.toIso8601String(),
    };
    
    if (restaurantId != null) {
      data['restaurantId'] = restaurantId;
    }
    
    if (kakaoPlaceId != null) {
      data['kakaoPlaceId'] = kakaoPlaceId;
    }
    
    if (notes != null) {
      data['notes'] = notes;
    }
    
    return data;
  }
}