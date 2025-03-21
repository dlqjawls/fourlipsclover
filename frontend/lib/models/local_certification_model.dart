import 'package:frontend/models/user_model.dart';

class LocalCertification {
  final int localCertificationId;
  final UserProfile member;
  final LocalRegion localRegion;
  final bool certificated;
  final DateTime certificatedAt;
  final DateTime expiryAt;
  final String localGrade;

  LocalCertification({
    required this.localCertificationId,
    required this.member,
    required this.localRegion,
    required this.certificated,
    required this.certificatedAt,
    required this.expiryAt,
    required this.localGrade,
  });

  factory LocalCertification.fromJson(Map<String, dynamic> json) {
    return LocalCertification(
      localCertificationId: json['localCertificationId'],
      member: UserProfile.fromJson(json['member']),
      localRegion: LocalRegion.fromJson(json['localRegion']),
      certificated: json['certificated'],
      certificatedAt: DateTime.parse(json['certificatedAt']),
      expiryAt: DateTime.parse(json['expiryAt']),
      localGrade: json['localGrade'],
    );
  }
}

class LocalRegion {
  final String localRegionId;
  final String regionName;

  LocalRegion({
    required this.localRegionId,
    required this.regionName,
  });

  factory LocalRegion.fromJson(Map<String, dynamic> json) {
    return LocalRegion(
      localRegionId: json['localRegionId'],
      regionName: json['regionName'],
    );
  }
}