import 'restaurant_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Review {
  final String id;
  final String restaurantId;
  final int memberId;
  final String username;
  final String? title;
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

  Review({
    required this.id,
    required this.restaurantId,
    required this.memberId,
    required this.username,
    this.title,
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
  });

  factory Review.fromResponse(ReviewResponse response) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final imageUrl = (response.reviewImageUrls.isNotEmpty)
        ? response.reviewImageUrls.first
        : null;

    final profileImageUrl = response.reviewer?.profileImageUrl;

    print('📸 리뷰 이미지 URL: $imageUrl');
    print('👤 작성자: ${response.reviewer?.nickname}, 리뷰 내용: ${response.content}');
    print('🧑‍💼 프로필 이미지 URL: $profileImageUrl');

    return Review(
      id: response.reviewId?.toString() ?? '',
      restaurantId: response.restaurant?.restaurantId?.toString() ?? '',
      memberId: response.reviewer?.memberId ?? 0,
      username: response.reviewer?.nickname ?? '익명',
      title: '리뷰',
      content: response.content,
      imageUrl: imageUrl,
      profileImageUrl: profileImageUrl ?? 'assets/default_profile.png',
      visitCount: 1,
      isLocal: false,
      localRank: 0,
      likes: response.likedCount,
      dislikes: response.dislikedCount,
      date: response.createdAt ?? DateTime.now(),
      menu: [],
      isLiked: false,
      isDisliked: false,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      memberId: json['member_id'] ?? 0,
      username: json['username'],
      title: json['title'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'member_id': memberId,
      'username': username,
      'title': title,
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
    };
  }
}