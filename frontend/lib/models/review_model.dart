class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String username;
  final String? title; // ✅ 제목 필드 추가
  final String content;
  final String? imageUrl;
  final String? profileImageUrl;
  final int visitCount;
  final bool isLocal;
  final int localRank;
  final int likes;
  final int dislikes;
  final DateTime date;
  final List<String> menu;
  bool isLiked;
  bool isDisliked;

  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.username,
    this.title, // ✅ 제목 필드 추가
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

  /// ✅ JSON 데이터를 Review 객체로 변환하는 생성자
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      userId: json['user_id'],
      username: json['username'],
      title: json['title'], // ✅ JSON에서 제목 가져오기
      content: json['content'],
      imageUrl: json['image_url'],
      profileImageUrl: json['profile_image_url'] ?? 'assets/default_profile.png',
      visitCount: json['visit_count'],
      isLocal: json['is_local'],
      localRank: json['local_rank'] is int ? json['local_rank'] : int.parse(json['local_rank']),
      likes: json['likes'],
      dislikes: json['dislikes'],
      date: DateTime.parse(json['date']),
      menu: (json['menu'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isLiked: json['is_liked'] ?? false,
      isDisliked: json['is_disliked'] ?? false,
    );
  }

  /// ✅ 객체를 JSON으로 변환하는 메서드 (필요한 경우)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'username': username,
      'title': title, // ✅ JSON 변환 시 제목 추가
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
