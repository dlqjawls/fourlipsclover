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
}

class UserProfile {
  final int userId;
  final String name;
  final String nickname;
  final String profileUrl;
  final List<Payment> recentPayments;
  final String badgeUrl;
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
    required this.badgeUrl,
    required this.localAuth,
    required this.albumCount,
    required this.groupCount,
    required this.reviewCount,
    required this.luckGauge,
    this.currentJourney,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
     userId: int.parse(json['userId']),
      name: json['name'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
      recentPayments: (json['recentPayments'] as List)
          .map((payment) => Payment.fromJson(payment))
          .toList(),
      badgeUrl: json['badgeUrl'],
      localAuth: json['localAuth'],
      albumCount: json['albumCount'],
      groupCount: json['groupCount'],
      reviewCount: json['reviewCount'],
      luckGauge: json['luckGauge'],
      currentJourney: json['currentJourney'],
    );
  }
}