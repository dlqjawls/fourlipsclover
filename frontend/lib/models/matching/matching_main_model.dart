class MatchRequest {
  final int matchId;
  final GuideRequestForm guideRequestForm;
  final int applicantId;
  final String regionName;
  final String createdAt;
  final String status;
  final int price;

  // GuideRequestForm의 필드들에 쉽게 접근하기 위한 getter 메서드들
  String get transportation => guideRequestForm.transportation;
  String get foodPreference => guideRequestForm.foodPreference;
  String get tastePreference => guideRequestForm.tastePreference;
  String get requirements => guideRequestForm.requirements;
  String get startDate => guideRequestForm.startDate;
  String get endDate => guideRequestForm.endDate;
  String get formCreatedAt => guideRequestForm.createdAt;
  String? get formUpdatedAt => guideRequestForm.updatedAt;
  int get formId => guideRequestForm.guideRequestFormId;

  MatchRequest({
    required this.matchId,
    required this.guideRequestForm,
    required this.applicantId,
    required this.regionName,
    required this.createdAt,
    required this.status,
    required this.price,
  });

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      matchId: json['matchId'] as int? ?? 0,
      guideRequestForm: GuideRequestForm.fromJson(json['guideRequestForm'] as Map<String, dynamic>),
      applicantId: json['applicantId'] as int? ?? 0,
      regionName: json['regionName'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      price: json['price'] as int? ?? 0,
    );
  }
}

class MatchApplication {
  
  final int matchId; 
  final String regionName;
  final String guideNickname;
  final String createdAt;
  final String startDate;
  final String endDate;
  final String status;

  MatchApplication({
    required this.matchId,
    required this.regionName,
    required this.guideNickname,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory MatchApplication.fromJson(Map<String, dynamic> json) {
    return MatchApplication(
      matchId: json['matchId'] as int? ?? 0,  // matchId 파싱 추가
      regionName: json['regionName'] as String? ?? '',
      guideNickname: json['guideNickname'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}

class GuideRequestForm {
  final int guideRequestFormId;
  final String transportation;
  final String foodPreference;
  final String tastePreference;
  final String requirements;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String? updatedAt;

  GuideRequestForm({
    required this.guideRequestFormId,
    required this.transportation,
    required this.foodPreference,
    required this.tastePreference,
    required this.requirements,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory GuideRequestForm.fromJson(Map<String, dynamic> json) {
    return GuideRequestForm(
      guideRequestFormId: json['guideRequestFormId'] as int? ?? 0,
      transportation: json['transportation'] as String? ?? '',
      foodPreference: json['foodPreference'] as String? ?? '',
      tastePreference: json['tastePreference'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}