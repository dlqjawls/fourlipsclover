class Payment {
  final String storeName;
  final String menu;
  final int paymentAmount;

  Payment({
    required this.storeName,
    required this.menu,
    required this.paymentAmount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      storeName: json['storeName'] ?? '',
      menu: json['menu'] ?? '',
      paymentAmount: json['paymentAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'menu': menu,
      'paymentAmount': paymentAmount,
    };
  }
}

class UserProfile {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl;
  final DateTime createdAt;
  final double trustScore;
  final int reviewCount;
  final int groupCount;
  final List<RecentPayment> recentPayments;
  final List<PlanResponse> planResponses;
  final bool localAuth;
  final String? localRank;
  final String? localRegion;
  final String? badgeName;
  final List<RestaurantTag> tags;

  UserProfile({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
    required this.createdAt,
    required this.trustScore,
    required this.reviewCount,
    required this.groupCount,
    required this.recentPayments,
    required this.planResponses,
    required this.localAuth,
    this.localRank,
    this.localRegion,
    this.badgeName,
    required this.tags,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      trustScore: json['trustScore'].toDouble(),
      reviewCount: json['reviewCount'],
      groupCount: json['groupCount'],
      recentPayments:
          (json['recentPayments'] as List)
              .map((e) => RecentPayment.fromJson(e))
              .toList(),
      planResponses:
          (json['planResponses'] as List)
              .map((e) => PlanResponse.fromJson(e))
              .toList(),
      localAuth: json['localAuth'],
      localRank: json['localRank'] as String?,
      localRegion: json['localRegion'] as String?,
      badgeName: json['badgeName'],
      tags:
          (json['tags'] as List).map((e) => RestaurantTag.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'email': email,
      'nickname': nickname,
      'profileUrl': profileUrl,
      'createdAt': createdAt.toIso8601String(),
      'trustScore': trustScore,
      'reviewCount': reviewCount,
      'groupCount': groupCount,
      'recentPayments': recentPayments.map((e) => e.toJson()).toList(),
      'planResponses': planResponses.map((e) => e.toJson()).toList(),
      'localAuth': localAuth,
      'localRank': localRank,
      'localRegion': localRegion,
      'badgeName': badgeName,
      'tags': tags.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentPayment {
  final String storeName;
  final int paymentAmount;

  RecentPayment({required this.storeName, required this.paymentAmount});

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    return RecentPayment(
      storeName: json['storeName'],
      paymentAmount: json['paymentAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'storeName': storeName, 'paymentAmount': paymentAmount};
  }
}

class PlanResponse {
  final int planId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  PlanResponse({
    required this.planId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      planId: json['planId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class RestaurantTag {
  final int restaurantTagId;
  final String tagName;
  final String category;

  RestaurantTag({
    required this.restaurantTagId,
    required this.tagName,
    required this.category,
  });

  factory RestaurantTag.fromJson(Map<String, dynamic> json) {
    return RestaurantTag(
      restaurantTagId: json['restaurantTagId'],
      tagName: json['tagName'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantTagId': restaurantTagId,
      'tagName': tagName,
      'category': category,
    };
  }
}
