import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_detail.dart';
import '../review/review_write.dart';
import '../../services/review_service.dart';

class ReviewList extends StatefulWidget {
  final String restaurantId;
  final VoidCallback onReviewUpdated;

  const ReviewList({Key? key, required this.restaurantId, required this.onReviewUpdated}) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late Future<List<Review>> reviewData;
  final List<String> defaultImages = [
    "assets/images/review_image.jpg",
    "assets/images/review_image2.jpg",
    "assets/images/review_image3.jpg"
  ];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  /// ✅ 리뷰 리스트 불러오기
  void _fetchReviews() {
    setState(() {
      reviewData = ReviewService.fetchReviews(widget.restaurantId);
    });
  }

  /// ✅ 리뷰 작성 후 리스트 자동 새로고침
  Future<void> _onReviewWritten() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewWriteScreen(kakaoPlaceId: widget.restaurantId),
      ),
    );
    if (updated == true) {
      await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 응답 딜레이 보정
      _fetchReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ "리뷰" 제목 + 리뷰 작성 버튼 추가
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Row(
            children: [
              Text("리뷰", style: Theme.of(context).textTheme.titleMedium),
              Spacer(),

              /// ✅ 리뷰 작성 버튼
              IconButton(
                icon: Icon(Icons.add, size: 24, color: AppColors.darkGray),
                onPressed: _onReviewWritten,
              ),
            ],
          ),
        ),

        /// ✅ 리뷰 리스트 FutureBuilder
        FutureBuilder<List<Review>>(
          future: reviewData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "에러 발생: ${snapshot.error}",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("아직 리뷰가 없습니다."));
            }

            return Column(
              children: snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final review = entry.value;

                return InkWell(
                  onTap: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetail(
                          review: review,
                          restaurantId: widget.restaurantId,
                        ),
                      ),
                    );
                    if (updated == true) {
                      _fetchReviews();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ 프로필 + 닉네임 + 방문 정보
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(review.profileImageUrl ?? 'assets/default_profile.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                review.username,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              "${review.visitCount}번째 방문 | ${_formatDate(review.date)}",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// ✅ 리뷰 내용 (최대 2줄)
                        Text(
                          review.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 8),

                        /// ✅ 리뷰 이미지 표시 (백엔드에서 안 주면 기본 이미지 사용)
                        _buildReviewImage(review.imageUrl, index),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// ✅ 리뷰 이미지 표시 (리뷰에 이미지가 없으면 기본 이미지 할당)
  Widget _buildReviewImage(String? imageUrl, int index) {
    String assignedImage = defaultImages[index % defaultImages.length]; // 3개 이미지 순환

    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = assignedImage; // 기본 이미지 할당
    }

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageUrl.startsWith("http") ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// ✅ 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
