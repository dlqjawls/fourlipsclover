import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/review_model.dart';
import 'review_detail.dart';
import 'review_write.dart';
import '../../services/review_service.dart';

class ReviewList extends StatelessWidget {
  final String restaurantId;
  final VoidCallback onReviewUpdated;

  const ReviewList({Key? key, required this.restaurantId, required this.onReviewUpdated}) : super(key: key);

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
              /// ✅ 리뷰 작성 버튼 (restaurantId 전달)
              IconButton(
                icon: Icon(Icons.add, size: 24, color: AppColors.darkGray),
                onPressed: () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewWriteScreen(
                        kakaoPlaceId: restaurantId, // ✅ restaurantId 전달
                      ),
                    ),
                  );
                  if (updated == true) {
                    onReviewUpdated();
                  }
                },
              ),
            ],
          ),
        ),

        /// ✅ 리뷰 리스트 FutureBuilder
        FutureBuilder<List<Review>>(
          future: ReviewService.fetchReviews(restaurantId),
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
              children: snapshot.data!.map((review) {
                return InkWell(
                  onTap: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetail(
                          review: review,
                          restaurantId: restaurantId, // ✅ restaurantId 추가
                        ),
                      ),
                    );
                    if (updated == true) {
                      onReviewUpdated();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ 리뷰 내용 (최대 2줄)
                        Text(review.content, maxLines: 2, overflow: TextOverflow.ellipsis),
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
}
