import 'package:flutter/material.dart';
import 'package:frontend/widgets/clover_loading_spinner.dart';
import '../../config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_write.dart';
import '../../services/review_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/review_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import 'package:frontend/utils/review_utils.dart';
import 'package:frontend/screens/review/widgets/delete_confirmation_modal.dart';
import '../review/widgets/review_options_modal.dart';
import 'review_photo_gallery.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      setState(() {
        accessToken = appProvider.jwtToken;
        memberId = userProvider.userProfile?.memberId ?? 0;
      });

      _fetchReviews();
    });
  }

  void _fetchReviews() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.jwtToken;

    reviewData = ReviewService.fetchReviews(
      widget.restaurantId,
      accessToken: token,
    ).then((reviews) {
      reviews.sort((a, b) => b.date.compareTo(a.date));
      Provider.of<ReviewProvider>(context, listen: false).setReviews(reviews);
      return reviews;
    });
  }

  Future<void> _toggleLike(String reviewId, String likeStatus) async {
    final provider = Provider.of<ReviewProvider>(context, listen: false);
    final review = provider.getReview(reviewId);

    if (review == null) return;

    if (review.memberId == memberId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("다른 이용자의 리뷰에 반응을 남겨주세요"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await ReviewService.toggleLikeStatus(
        reviewId: int.parse(review.id),
        memberId: memberId,
        likeStatus: likeStatus,
        accessToken: accessToken!,
      );

      provider.toggleLike(reviewId, likeStatus);
    } catch (e) {
      print("❌ 좋아요/싫어요 처리 오류: $e");
    }
  }


  Future<void> _onReviewWritten() async {
    final createdReview = await showReviewBottomSheet(
      context: context,
      kakaoPlaceId: widget.restaurantId,
    );

    if (createdReview != null) {
      widget.onReviewUpdated();
      _fetchReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Row(
            children: [
              Text("리뷰", style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(
                    Icons.add, size: 24, color: AppColors.darkGray),
                onPressed: _onReviewWritten,
              ),
            ],
          ),
        ),

        FutureBuilder<List<Review>>(
          future: reviewData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CloverLoadingSpinner());
            } else if (snapshot.hasError) {
              return Center(child: Text("에러 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("아직 리뷰가 없습니다."));
            }

            final reviews = snapshot.data!;

            return Column(
              children: reviews
                  .asMap()
                  .entries
                  .map<Widget>((entry) {
                final index = entry.key;
                final review = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: _buildProfileImageProvider(
                                review.profileImageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(review.username, style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge),
                          ),
                          Text(
                            "${review.visitCount}번째 방문 | ${_formatDate(
                                review.date)}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          if (review.memberId == memberId)
                            GestureDetector(
                              onTapDown: (details) {
                                final tapPosition = details.globalPosition;
                                showReviewOptionsModal(
                                  context: context,
                                  position: tapPosition,
                                  review: review,
                                  kakaoPlaceId: widget.restaurantId,
                                  onReviewUpdated: () {
                                    widget.onReviewUpdated();
                                    _fetchReviews();
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.more_vert, size: 20,
                                    color: Colors.grey[600]),
                              ),
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
                      // 변경된 이미지 처리
                      _buildReviewImage(review),
                      const SizedBox(height: 8),
                      Consumer<ReviewProvider>(
                        builder: (context, provider, _) {
                          final currentReview = provider.getReview(review.id);
                          if (currentReview == null) return SizedBox.shrink();
                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  size: 18,
                                  color: currentReview.isLiked ? AppColors
                                      .primary : AppColors.lightGray,
                                ),
                                onPressed: () {
                                  if (currentReview.memberId == memberId) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("다른 이용자의 리뷰에 반응을 남겨주세요."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    _toggleLike(currentReview.id, "LIKE");
                                  }
                                },
                              ),
                              Text('${currentReview.likes}',
                                  style: const TextStyle(fontSize: 12)),
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_down,
                                  size: 18,
                                  color: currentReview.isDisliked ? AppColors
                                      .primary : AppColors.lightGray,
                                ),
                                onPressed: () {
                                  if (currentReview.memberId == memberId) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("다른 이용자의 리뷰에 반응을 남겨주세요."),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    _toggleLike(currentReview.id, "DISLIKE");
                                  }
                                },
                              ),
                              Text('${currentReview.dislikes}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          );
                        },
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

  Widget _buildReviewImage(Review review) {
    final imageUrls = review.imageUrls;
    if (imageUrls == null || imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final aspectRatio = 4 / 3;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReviewPhotoGallery(
              review: review,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrls.length == 1
              ? Image(
            image: imageUrls.first.startsWith("http")
                ? NetworkImage(imageUrls.first)
                : AssetImage(imageUrls.first) as ImageProvider,
            fit: BoxFit.cover,
          )
              : Stack(
            children: [
              PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, pageIndex) {
                  return Image(
                    image: imageUrls[pageIndex].startsWith("http")
                        ? NetworkImage(imageUrls[pageIndex])
                        : AssetImage(imageUrls[pageIndex]) as ImageProvider,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "1/${imageUrls.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
