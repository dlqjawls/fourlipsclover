// models/plan_model.dart
class Plan {
  final int planId;
  final int groupId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Bundle? defaultBundle;
  final List<PlanPlace> planPlaces;

  Plan({
    required this.planId,
    required this.groupId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    this.defaultBundle,
    this.planPlaces = const [],
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      planId: json['planId'],
      groupId: json['groupId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      defaultBundle: json['defaultBundle'] != null ? Bundle.fromJson(json['defaultBundle']) : null,
      // planPlaces는 별도로 로드
    );
  }
}

// Bundle 모델 (사진 묶음)
class Bundle {
  final int bundleId;
  final String name;
  final String description;
  final DateTime createdAt;

  Bundle({
    required this.bundleId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      bundleId: json['bundleId'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// 장소 모델
class Place {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? contactNumber;
  final double? averageRating;
  final int? reviewCount;

  Place({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactNumber,
    this.averageRating,
    this.reviewCount,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      contactNumber: json['contactNumber'],
      averageRating: json['averageRating'],
      reviewCount: json['reviewCount'],
    );
  }
}

// 계획 장소 모델 (세부 일정)
class PlanPlace {
  final int planPlaceId;
  final int planId;
  final int placeId;
  final String notes;
  final DateTime visitAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Place place;

  PlanPlace({
    required this.planPlaceId,
    required this.planId,
    required this.placeId,
    required this.notes,
    required this.visitAt,
    required this.createdAt,
    this.updatedAt,
    required this.place,
  });

  factory PlanPlace.fromJson(Map<String, dynamic> json) {
    return PlanPlace(
      planPlaceId: json['planPlaceId'],
      planId: json['planId'],
      placeId: json['placeId'],
      notes: json['notes'],
      visitAt: DateTime.parse(json['visitAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      place: Place.fromJson(json['place']),
    );
  }
}