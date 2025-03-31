class MatchingDetail {
  final String regionName;
  final String guideNickname;
  final String status;
  final String foodPreference;
  final String requirements;
  final String tastePreference;
  final String transportation;
  final String startDate;
  final String endDate;
  final String createdAt;

  MatchingDetail({
    required this.regionName,
    required this.guideNickname,
    required this.status,
    required this.foodPreference,
    required this.requirements,
    required this.tastePreference,
    required this.transportation,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory MatchingDetail.fromJson(Map<String, dynamic> json) {
    return MatchingDetail(
      regionName: json['regionName'] ?? '',
      guideNickname: json['guideNickname'] ?? '',
      status: json['status'] ?? '',
      foodPreference: json['foodPreference'] ?? '',
      requirements: json['requirements'] ?? '',
      tastePreference: json['tastePreference'] ?? '',
      transportation: json['transportation'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
