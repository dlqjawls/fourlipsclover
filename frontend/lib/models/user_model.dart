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
      storeName: json['storeName'],
      menu: json['menu'],
      paymentAmount: json['paymentAmount'],
    );
  }

  // Payment toJson 메서드 추가
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
  final String? currentJourney;

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
    this.currentJourney,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      name: json['name'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
      recentPayments:
          (json['recentPayments'] as List)
              .map((payment) => Payment.fromJson(payment))
              .toList(),
      badgeName: json['badgeName'],
      localAuth: json['localAuth'],
      albumCount: json['albumCount'],
      groupCount: json['groupCount'],
      reviewCount: json['reviewCount'],
      luckGauge: json['luckGauge'],
      currentJourney: json['currentJourney'],
    );
  }

  // UserProfile toJson 메서드 추가
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
