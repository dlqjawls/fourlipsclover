import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_detail.dart';
import '../review/review_write.dart';
import '../../services/review_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewList extends StatefulWidget {
  final String restaurantId;
  final VoidCallback onReviewUpdated;

  const ReviewList({
    Key? key,
    required this.restaurantId,
    required this.onReviewUpdated,
  }) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late Future<List<Review>> reviewData;
  String? accessToken;
  int memberId = 0;

  final List<String> defaultImages = [
    "assets/images/review_image.jpg",
    "assets/images/review_image2.jpg",
    "assets/images/review_image3.jpg"
  ];

  @override
  void initState() {
    super.initState();
    _loadAuthInfo();
    _fetchReviews();
  }

  Future<void> _loadAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    final parsedId = int.tryParse(userIdStr ?? '');
    setState(() {
      accessToken = prefs.getString("jwtToken");
      memberId = parsedId ?? 0;
    });
  }

  void _fetchReviews() {
    setState(() {
      reviewData = ReviewService.fetchReviews(widget.restaurantId).then((reviews) {
        reviews.sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
        return reviews;
      });
    });
  }

  Future<void> _toggleLike(Review review, String likeStatus) async {
    if (review.memberId == memberId) return;

    try {
      final message = await ReviewService.toggleLikeStatus(
        reviewId: int.parse(review.id),
        memberId: memberId,
        likeStatus: likeStatus,
        accessToken: accessToken!,
      );

      setState(() {
        if (likeStatus == "LIKE") {
          review.isLiked = !review.isLiked;
          review.likes += review.isLiked ? 1 : -1;
          if (review.isDisliked) {
            review.isDisliked = false;
            review.dislikes -= 1;
          }
        } else {
          review.isDisliked = !review.isDisliked;
          review.dislikes += review.isDisliked ? 1 : -1;
          if (review.isLiked) {
            review.isLiked = false;
            review.likes -= 1;
          }
        }
      });
    } catch (e) {
      print("❌ 좋아요/싫어요 처리 오류: $e");
    }
  }

  Future<void> _onReviewWritten() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewWriteScreen(kakaoPlaceId: widget.restaurantId),
      ),
    );
    if (updated == true) {
      await Future.delayed(const Duration(milliseconds: 500));
      _fetchReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ 리뷰 제목 + 작성 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Row(
            children: [
              Text("리뷰", style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 24, color: AppColors.darkGray),
                onPressed: _onReviewWritten,
              ),
            ],
          ),
        ),

        /// ✅ 리뷰 리스트
        FutureBuilder<List<Review>>(
          future: reviewData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("에러 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("아직 리뷰가 없습니다."));
            }

            final reviews = snapshot.data!;

            return Column(
              children: reviews.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final review = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: review.memberId != memberId
                            ? null
                            : () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetail(
                                review: review,
                                restaurantId: widget.restaurantId,
                              ),
                            ),
                          );

                          if (updated == true) {
                            _fetchReviews(); // ✅ 무조건 다시 불러오기
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: _buildProfileImageProvider(review.profileImageUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(review.username, style: Theme.of(context).textTheme.bodyLarge),
                                ),
                                Text(
                                  "${review.visitCount}번째 방문 | ${_formatDate(review.date)}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              review.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            _buildReviewImage(review.imageUrl, index),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    size: 18,
                                    color: review.isLiked ? AppColors.primary : AppColors.lightGray,
                                  ),
                                  onPressed: review.memberId == memberId
                                      ? null
                                      : () => _toggleLike(review, "LIKE"),
                                ),
                                Text('${review.likes}', style: const TextStyle(fontSize: 12)),
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_down,
                                    size: 18,
                                    color: review.isDisliked ? AppColors.primary : AppColors.lightGray,
                                  ),
                                  onPressed: review.memberId == memberId
                                      ? null
                                      : () => _toggleLike(review, "DISLIKE"),
                                ),
                                Text('${review.dislikes}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            if (index < reviews.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 0.7,
                                  height: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }


  ImageProvider _buildProfileImageProvider(String? imageUrl) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://your-api.com';

    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/default_profile.png');
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      return NetworkImage('$baseUrl/uploads/profile/$imageUrl');
    }
  }

  Widget _buildReviewImage(String? imageUrl, int index) {
    String assignedImage = defaultImages[index % defaultImages.length];

    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = assignedImage;
    }

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageUrl.startsWith("http")
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
