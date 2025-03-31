class MatchRequest {
  final int matchId;
  final int applicantId;
  final String regionName;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String status;
  final int price;

  MatchRequest({
    required this.matchId,
    required this.applicantId,
    required this.regionName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.status,
    required this.price,
  });

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      matchId: json['matchId'],
      applicantId: json['applicantId'],
      regionName: json['regionName'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createdAt: json['createdAt'],
      status: json['status'],
      price: json['price'],
    );
  }
}

class MatchApplication {
  final String regionName;
  final String guideNickname;
  final String createdAt;
  final String startDate;
  final String endDate;
  final String status;

  MatchApplication({
    required this.regionName,
    required this.guideNickname,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory MatchApplication.fromJson(Map<String, dynamic> json) {
    return MatchApplication(
      regionName: json['regionName'],
      guideNickname: json['guideNickname'],
      createdAt: json['createdAt'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
    );
  }
}