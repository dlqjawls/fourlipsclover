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
    try {
      return MatchingDetail(
        regionName: json['regionName'] as String? ?? '',
        guideNickname: json['guideNickname'] as String? ?? '',
        status: json['status'] as String? ?? 'PENDING',
        foodPreference: json['foodPreference'] as String? ?? '',
        requirements: json['requirements'] as String? ?? '',
        tastePreference: json['tastePreference'] as String? ?? '',
        transportation: json['transportation'] as String? ?? '',
        startDate: json['startDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('매칭 상세 정보 파싱 실패: $e');
    }
  }

  // API 응답을 위한 toJson 메서드
  Map<String, dynamic> toJson() => {
    'regionName': regionName,
    'guideNickname': guideNickname,
    'status': status,
    'foodPreference': foodPreference,
    'requirements': requirements,
    'tastePreference': tastePreference,
    'transportation': transportation,
    'startDate': startDate,
    'endDate': endDate,
    'createdAt': createdAt,
  };

  // 디버깅을 위한 toString 메서드
  @override
  String toString() {
    return 'MatchingDetail('
        'regionName: $regionName, '
        'guideNickname: $guideNickname, '
        'status: $status, '
        'foodPreference: $foodPreference, '
        'requirements: $requirements, '
        'tastePreference: $tastePreference, '
        'transportation: $transportation, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'createdAt: $createdAt)';
  }
}

// 매칭 상세 조회 관련 예외 클래스
class MatchingDetailException implements Exception {
  final String message;
  final int? statusCode;

  MatchingDetailException(this.message, [this.statusCode]);

  @override
  String toString() => 
    statusCode != null ? 
    '매칭 상세 조회 오류 ($statusCode): $message' : 
    '매칭 상세 조회 오류: $message';
}