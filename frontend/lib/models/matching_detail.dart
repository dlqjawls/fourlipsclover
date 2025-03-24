class MatchingDetail {
  final int matchId;
  final String status;
  final User user;
  final Local local;
  final City city;
  final Schedule schedule;
  final Details details;
  final Timestamps timestamps;

  MatchingDetail.fromJson(Map<String, dynamic> json)
    : matchId = json['match_id'],
      status = json['status'],
      user = User.fromJson(json['user']),
      local = Local.fromJson(json['local']),
      city = City.fromJson(json['city']),
      schedule = Schedule.fromJson(json['schedule']),
      details = Details.fromJson(json['details']),
      timestamps = Timestamps.fromJson(json['timestamps']);
}

class User {
  final int userId;
  final String nickname;
  final String profileImg;

  User.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'],
      nickname = json['nickname'],
      profileImg = json['profile_img'];
}

class Local {
  final int userId;
  final String nickname;
  final String profileImg;
  final Certification certification;

  Local.fromJson(Map<String, dynamic> json)
    : userId = json['user_id'],
      nickname = json['nickname'],
      profileImg = json['profile_img'],
      certification = Certification.fromJson(json['certification']);
}

class Certification {
  final int cityId;
  final String cityName;
  final bool isCertified;
  final DateTime certifiedAt;
  final DateTime expiryAt;

  Certification.fromJson(Map<String, dynamic> json)
    : cityId = json['city_id'],
      cityName = json['city_name'],
      isCertified = json['is_certified'],
      certifiedAt = DateTime.parse(json['certified_at']),
      expiryAt = DateTime.parse(json['expiry_at']);
}

class City {
  final int cityId;
  final String cityName;
  final String regionName;

  City.fromJson(Map<String, dynamic> json)
    : cityId = json['city_id'],
      cityName = json['city_name'],
      regionName = json['region_name'];
}

class Schedule {
  final DateTime startDate;
  final DateTime endDate;

  Schedule.fromJson(Map<String, dynamic> json)
    : startDate = DateTime.parse(json['start_date']),
      endDate = DateTime.parse(json['end_date']);
}

class Details {
  final String userMessage;
  final String localMessage;
  final int budget;
  final List<String> preferences;

  Details.fromJson(Map<String, dynamic> json)
    : userMessage = json['user_message'],
      localMessage = json['local_message'],
      budget = json['budget'],
      preferences = List<String>.from(json['preferences']);
}

class Timestamps {
  final DateTime createdAt;
  final DateTime updatedAt;

  Timestamps.fromJson(Map<String, dynamic> json)
    : createdAt = DateTime.parse(json['created_at']),
      updatedAt = DateTime.parse(json['updated_at']);
}
