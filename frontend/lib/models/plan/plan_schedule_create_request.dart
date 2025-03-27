class PlanScheduleCreateRequest {
  final int? restaurantId;
  final String? kakaoPlaceId; // 카카오 Place ID 추가
  final String? notes;
  final DateTime visitAt;

  PlanScheduleCreateRequest({
    this.restaurantId,
    this.kakaoPlaceId,
    this.notes,
    required this.visitAt,
  }) {
    // 최소한 하나의 ID는 제공되어야 함
    assert(restaurantId != null || kakaoPlaceId != null, 
      'restaurantId 또는 kakaoPlaceId 중 최소한 하나는 필수입니다.');
  }

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