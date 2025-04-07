import 'restaurant_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Review {
  final String id;
  final String restaurantId;
  final int memberId;
  final String username;
  final String content;
  final String? imageUrl;
  final String? profileImageUrl;
  final int visitCount;
  final bool isLocal;
  final int localRank;
  int likes;
  int dislikes;
  final DateTime date;
  final List<String> menu;
  bool isLiked;
  bool isDisliked;
  final List<String> imageUrls;

  Review({
    required this.id,
    required this.restaurantId,
    required this.memberId,
    required this.username,
    required this.content,
    this.imageUrl,
    this.profileImageUrl,
    required this.visitCount,
    required this.isLocal,
    required this.localRank,
    required this.likes,
    required this.dislikes,
    required this.date,
    required this.menu,
    this.isLiked = false,
    this.isDisliked = false,
    required this.imageUrls,
  });

  factory Review.fromResponse(ReviewResponse response) {
    final imageUrl = (response.reviewImageUrls.isNotEmpty)
        ? response.reviewImageUrls.first
        : null;

    final profileImageUrl = response.reviewer?.profileImageUrl;

    // 필수 값 없으면 null 반환 (리뷰 무시)
    if (response.reviewId == null || response.reviewer == null || response.restaurant == null) {
      print("⚠️ 필수 데이터 누락으로 리뷰 제외: $response");
      throw Exception("리뷰 필수 데이터 누락");
    }

    String normalizeUrl(String url) {
      if (url.startsWith('http')) return url;
      return 'http://43.203.123.220:9000/review-images/$url';
    }

    return Review(
      id: response.reviewId.toString(),
      restaurantId: response.restaurant!.kakaoPlaceId,
      memberId: response.reviewer!.memberId,
      username: response.reviewer!.nickname ?? '익명',
      content: response.content,
      imageUrl: imageUrl,
      profileImageUrl: profileImageUrl ?? 'assets/default_profile.png',
      visitCount: 1,
      isLocal: false,
      localRank: 0,
      likes: response.likedCount,
      dislikes: response.dislikedCount,
      date: response.visitedAt ?? DateTime.now(),
      menu: [],
        isLiked: response.userLiked ?? false,
        isDisliked: response.userDisliked ?? false,
      imageUrls: response.reviewImageUrls.map((url) => normalizeUrl(url)).toList(),
    );
  }



  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      memberId: json['member_id'] ?? 0,
      username: json['username'],
      content: json['content'],
      imageUrl: json['image_url'],
      profileImageUrl: json['profile_image_url'] ?? 'assets/default_profile.png',
      visitCount: json['visit_count'],
      isLocal: json['is_local'],
      localRank: json['local_rank'] is int
          ? json['local_rank']
          : int.parse(json['local_rank']),
      likes: json['likes'],
      dislikes: json['dislikes'],
      date: DateTime.parse(json['date']),
      menu: (json['menu'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isLiked: json['is_liked'] ?? false,
      isDisliked: json['is_disliked'] ?? false,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'member_id': memberId,
      'username': username,
      'content': content,
      'image_url': imageUrl,
      'profile_image_url': profileImageUrl,
      'visit_count': visitCount,
      'is_local': isLocal,
      'local_rank': localRank,
      'likes': likes,
      'dislikes': dislikes,
      'date': date.toIso8601String(),
      'menu': menu,
      'is_liked': isLiked,
      'is_disliked': isDisliked,
      'image_urls': imageUrls,
    };
  }
}