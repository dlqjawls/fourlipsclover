import 'package:intl/intl.dart';
import 'dart:convert';

/// 레스토랑 정보 모델
class RestaurantResponse {
  final int? restaurantId;
  final String kakaoPlaceId;
  final String? placeName;
  final String? addressName;
  final String? roadAddressName;
  final String? category;
  final String? categoryName;
  final String? phone;
  final String? placeUrl;
  final double? x;
  final double? y;
  final Map<String, String>? openingHours;
  final List<String>? restaurantImages;
  final List<String>? menu;
  final List<Map<String, dynamic>>? tags;
  final Map<String, dynamic>? avgAmount;
  final int? likeSentiment;
  final int? dislikeSentiment;
  final double? score;
  double? distance;

  RestaurantResponse({
    this.restaurantId,
    required this.kakaoPlaceId,
    this.placeName,
    this.addressName,
    this.roadAddressName,
    this.category,
    this.categoryName,
    this.phone,
    this.placeUrl,
    this.x,
    this.y,
    this.openingHours,
    this.restaurantImages,
    this.distance,
    this.tags,
    this.avgAmount,
    this.menu,
    this.likeSentiment,
    this.dislikeSentiment,
    this.score,
  });

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantResponse(
      restaurantId: json['restaurantId'],
      kakaoPlaceId: json['kakaoPlaceId'],
      placeName: json['placeName'],
      addressName: json['addressName'],
      roadAddressName: json['roadAddressName'],
      category: json['category'],
      categoryName: json['categoryName'],
      phone: json['phone'],
      placeUrl: json['placeUrl'],
      x: json['x'],
      y: json['y'],
      menu: (json['menu'] as List?)?.map((item) => item.toString()).toList(),
      openingHours:
          json['openingHours'] != null
              ? Map<String, String>.from(jsonDecode(json['openingHours']))
              : null,
      restaurantImages:
          (json['restaurantImages'] as List<dynamic>?)
              ?.map((img) => img.toString())
              .toList(),
      tags: (json['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      avgAmount:
          json['avgAmount'] != null
              ? Map<String, dynamic>.from(jsonDecode(json['avgAmount']))
              : null,
      likeSentiment: json['likeSentiment'],
      dislikeSentiment: json['dislikeSentiment'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'kakaoPlaceId': kakaoPlaceId,
      'placeName': placeName,
      'addressName': addressName,
      'roadAddressName': roadAddressName,
      'category': category,
      'categoryName': categoryName,
      'phone': phone,
      'placeUrl': placeUrl,
      'x': x,
      'y': y,
      'openingHours': openingHours,
      'restaurantImages': restaurantImages,
      'distance': distance,
      'tags': tags,
      'menu': menu,
      'score': score,
    };
  }
}

/// 리뷰 작성자 정보 모델
class ReviewMemberResponse {
  final int memberId;
  final String? name;
  final String? nickname;
  final String? email;
  final String? profileImageUrl;

  ReviewMemberResponse({
    required this.memberId,
    this.name,
    this.nickname,
    this.email,
    this.profileImageUrl,
  });

  factory ReviewMemberResponse.fromJson(Map<String, dynamic> json) {
    return ReviewMemberResponse(
      memberId: json['memberId'],
      name: json['name'],
      nickname: json['nickname'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

/// 리뷰의 레스토랑 정보 모델
class ReviewRestaurantResponse {
  final int? restaurantId;
  final String kakaoPlaceId;
  final String? placeName;
  final String? addressName;
  final String? roadAddressName;
  final String? category;
  final String? categoryName;

  ReviewRestaurantResponse({
    this.restaurantId,
    required this.kakaoPlaceId,
    this.placeName,
    this.addressName,
    this.roadAddressName,
    this.category,
    this.categoryName,
  });

  factory ReviewRestaurantResponse.fromJson(Map<String, dynamic> json) {
    return ReviewRestaurantResponse(
      restaurantId: json['restaurantId'],
      kakaoPlaceId: json['kakaoPlaceId'],
      placeName: json['placeName'],
      addressName: json['addressName'],
      roadAddressName: json['roadAddressName'],
      category: json['category'],
      categoryName: json['categoryName'],
    );
  }
}

/// 리뷰 응답 모델
class ReviewResponse {
  final int? reviewId;
  final ReviewMemberResponse? reviewer;
  final ReviewRestaurantResponse? restaurant;
  final String content;
  final DateTime? visitedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> reviewImageUrls;
  final int likedCount;
  final int dislikedCount;
  final bool? userLiked;
  final bool? userDisliked;

  ReviewResponse({
    this.reviewId,
    this.reviewer,
    this.restaurant,
    required this.content,
    this.visitedAt,
    this.createdAt,
    this.updatedAt,
    required this.reviewImageUrls,
    required this.likedCount,
    required this.dislikedCount,
    this.userLiked,
    this.userDisliked,

  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      reviewId: json['reviewId'],
      reviewer:
          json['reviewer'] != null
              ? ReviewMemberResponse.fromJson(json['reviewer'])
              : null,
      restaurant:
          json['restaurant'] != null
              ? ReviewRestaurantResponse.fromJson(json['restaurant'])
              : null,
      content: json['content'],
      visitedAt:
          json['visitedAt'] != null ? DateTime.parse(json['visitedAt']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      reviewImageUrls: List<String>.from(json['reviewImageUrls'] ?? []),
      likedCount: json['likedCount'] ?? 0,
      dislikedCount: json['dislikedCount'] ?? 0,
      userLiked: json['userLiked'],
      userDisliked: json['userDisliked'],
    );
  }

  String get formattedVisitedAt =>
      visitedAt == null ? '' : DateFormat('yyyy.MM.dd').format(visitedAt!);
  String get formattedCreatedAt =>
      createdAt == null
          ? ''
          : DateFormat('yyyy.MM.dd HH:mm').format(createdAt!);
}

/// 리뷰 생성 요청 모델
class ReviewCreate {
  final int memberId;
  final String kakaoPlaceId;
  final String content;
  final DateTime visitedAt;

  ReviewCreate({
    required this.memberId,
    required this.kakaoPlaceId,
    required this.content,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'kakaoPlaceId': kakaoPlaceId,
      'content': content,
      'visitedAt': visitedAt.toIso8601String(),
    };
  }
}

/// 리뷰 수정 요청 모델
class ReviewUpdate {
  final String content;
  final DateTime visitedAt;

  ReviewUpdate({required this.content, required this.visitedAt});

  Map<String, dynamic> toJson() {
    return {'content': content, 'visitedAt': visitedAt.toIso8601String()};
  }
}

/// 리뷰 삭제 응답 모델
class ReviewDeleteResponse {
  final String message;
  final int? reviewId;

  ReviewDeleteResponse({required this.message, this.reviewId});

  factory ReviewDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ReviewDeleteResponse(
      message: json['message'] ?? '',
      reviewId: json['reviewId'],
    );
  }
}
