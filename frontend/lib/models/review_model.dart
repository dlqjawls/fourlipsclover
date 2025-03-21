import 'restaurant_models.dart';

class Review {
  final String id;
  final String restaurantId;
  final int memberId;
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
    required this.memberId,
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

  /// ✅ `ReviewResponse` → `Review` 변환 생성자 추가
  factory Review.fromResponse(ReviewResponse response) {
    return Review(
      id: response.reviewId?.toString() ?? '',
      restaurantId: response.restaurant?.restaurantId?.toString() ?? '',
      memberId: response.reviewer?.memberId ?? 0,
      username: response.reviewer?.nickname ?? '익명',
      title: '리뷰', // 백엔드 응답에 없으므로 기본값 설정
      content: response.content,
      imageUrl: null, // 백엔드 응답에서 이미지 URL 제공되지 않음
      profileImageUrl: null, // 프로필 이미지도 기본값 (필요하면 response에 추가)
      visitCount: 1, // 백엔드에서 방문 횟수 제공되지 않음
      isLocal: false,
      localRank: 0,
      likes: 0, // 백엔드에서 좋아요 정보 없음
      dislikes: 0,
      date: response.visitedAt ?? DateTime.now(),
      menu: [],
      isLiked: false, // 백엔드 응답에 해당 정보 없음
      isDisliked: false,
    );
  }

  /// ✅ JSON 데이터를 Review 객체로 변환하는 생성자
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '0', // 기본값 설정
      restaurantId: json['restaurant_id'] ?? '0',
      memberId: json['member_id'] ?? 0,
      username: json['username'] ?? '익명', // ✅ 기본값: '익명'
      title: json['title'] ?? '리뷰 제목 없음', // ✅ 기본값 추가
      content: json['content'] ?? '내용 없음', // ✅ 기본값 추가
      imageUrl: json['image_url'] ?? "https://source.unsplash.com/400x300/?food",
      profileImageUrl: json['profile_image_url'] ?? "https://randomuser.me/api/portraits/men/1.jpg",
      visitCount: json['visit_count'] ?? 1, // ✅ 기본값: 1회 방문
      isLocal: json['is_local'] ?? false,
      localRank: json['local_rank'] is int ? json['local_rank'] : (json['local_rank'] != null ? int.parse(json['local_rank']) : 0),
      likes: json['likes'] ?? 0, // ✅ 기본값: 좋아요 0개
      dislikes: json['dislikes'] ?? 0, // ✅ 기본값: 싫어요 0개
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      menu: (json['menu'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['메뉴 정보 없음'], // ✅ 기본값 추가
      isLiked: json['is_liked'] ?? false,
      isDisliked: json['is_disliked'] ?? false,
    );
  }


  /// ✅ 객체를 JSON으로 변환하는 메서드 (필요한 경우)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'member_id': memberId,
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
  Review copyWith({
    String? id,
    String? restaurantId,
    int? memberId,
    String? username,
    String? title,
    String? content,
    String? imageUrl,
    String? profileImageUrl,
    int? visitCount,
    bool? isLocal,
    int? localRank,
    int? likes,
    int? dislikes,
    DateTime? date,
    List<String>? menu,
    bool? isLiked,
    bool? isDisliked,
  }) {
    return Review(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      memberId: memberId ?? this.memberId,
      username: username ?? this.username,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      visitCount: visitCount ?? this.visitCount,
      isLocal: isLocal ?? this.isLocal,
      localRank: localRank ?? this.localRank,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      date: date ?? this.date, // ✅ 날짜 변경 가능
      menu: menu ?? this.menu,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }
}
