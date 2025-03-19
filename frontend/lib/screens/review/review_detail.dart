import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import '../../models/review_model.dart';
import 'widgets/review_options_modal.dart';

class ReviewDetail extends StatelessWidget {
  final Review review;

  const ReviewDetail({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset? tapPosition;

    return Scaffold(
      appBar: AppBar(
        title: Text("리뷰 상세"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ 리뷰 제목 + 점 3개 아이콘 추가 (if문 유지)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (review.title != null && review.title!.isNotEmpty)
                    Expanded(
                      child: Text(
                        review.title!,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  /// ✅ 점 3개 아이콘 (오른쪽 정렬)
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      tapPosition = details.globalPosition; // ✅ 클릭 위치 저장
                    },
                    child: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {
                        if (tapPosition != null) {
                          showReviewOptionsModal(context, review, tapPosition!); // ✅ 작은 모달 실행
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 프로필 + 닉네임 + 방문 횟수 & 방문 날짜 (오른쪽 정렬)
              Row(
                children: [
                  /// 프로필 이미지
                  CircleAvatar(
                    backgroundImage: NetworkImage(review.profileImageUrl ?? 'assets/default_profile.png'),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),

                  /// 닉네임
                  Expanded(
                    child: Text(
                      review.username,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  /// 방문 횟수 & 날짜 (한 줄 | 구분자로 정렬)
                  Text(
                    "${review.visitCount}번째 방문 | ${_formatDate(review.date)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 구분선 (border)
              Divider(color: Colors.grey[300], thickness: 1),

              const SizedBox(height: 12),

              /// 리뷰 사진 (없을 경우 기본 회색 박스)
              _buildReviewImage(review.imageUrl),

              const SizedBox(height: 12),

              /// 리뷰 내용
              Text(
                review.content,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 리뷰 이미지 (없으면 회색 박스)
  Widget _buildReviewImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color:AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        image: (imageUrl != null && imageUrl.isNotEmpty)
            ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )
            : null,  // 이미지가 없을 경우 기본 박스 유지
      ),
    );
  }

  /// 날짜 포맷 변경 (YYYY-MM-DD → MM.DD)
  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
