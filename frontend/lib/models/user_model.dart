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
  final String userId;
  final String name;
  final String nickname;
  final String profileUrl;
  final List<Payment> recentPayments;
  final String badgeName;
  final bool localAuth;
  final int albumCount;
  final int groupCount;
  final int reviewCount;
  final int luckGauge;
  final String currentJourney;

  UserProfile({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.profileUrl,
    required this.recentPayments,
    required this.badgeName,
    required this.localAuth,
    required this.albumCount,
    required this.groupCount,
    required this.reviewCount,
    required this.luckGauge,
    required this.currentJourney,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'].toString(),
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      recentPayments:
          (json['recentPayments'] as List<dynamic>? ?? [])
              .map(
                (payment) => Payment.fromJson(payment as Map<String, dynamic>),
              )
              .toList(),
      badgeName: json['badgeName'] ?? '',
      localAuth: json['localAuth'] ?? false,
      albumCount: json['albumCount'] ?? 0,
      groupCount: json['groupCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      luckGauge: json['luckGauge'] ?? 0,
      currentJourney: json['currentJourney'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'nickname': nickname,
      'profileUrl': profileUrl,
      'recentPayments':
          recentPayments.map((payment) => payment.toJson()).toList(),
      'badgeName': badgeName,
      'localAuth': localAuth,
      'albumCount': albumCount,
      'groupCount': groupCount,
      'reviewCount': reviewCount,
      'luckGauge': luckGauge,
      'currentJourney': currentJourney,
    };
  }
}
