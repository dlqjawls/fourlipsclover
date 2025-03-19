import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import '../../models/review_model.dart';
import 'review_detail.dart';  // 파일명 변경됨
import 'review_write.dart';

class ReviewList extends StatelessWidget {
  final Future<List<Review>> reviews;

  const ReviewList({Key? key, required this.reviews}) : super(key: key);

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
              /// ✅ 오른쪽에 + 버튼 추가 (리뷰 작성 페이지 이동)
              IconButton(
                icon: Icon(Icons.add, size: 24, color: AppColors.darkGray),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewWriteScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<Review>>(
          future: reviews,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text("아직 리뷰가 없습니다."));
            }

            return Column(
              children: snapshot.data!.map((review) {
                return InkWell(
                  onTap: () {
                    // 리뷰 클릭 시 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetail(review: review),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 프로필 + 닉네임 + 현지인 정보 + 방문 횟수 & 날짜 (한 줄 표시)
                        Row(
                          children: [
                            /// 프로필 이미지
                            CircleAvatar(
                              backgroundImage: NetworkImage(review.profileImageUrl ?? 'assets/default_profile.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),

                            /// 닉네임 + 현지인 여부
                            Expanded(
                              child: Row(
                                children: [
                                  Text(review.username, style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(width: 6),

                                  /// 현지인 여부 및 랭크
                                  if (review.isLocal) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "현지인 ${review.localRank}",
                                        style: TextStyle(color: AppColors.verylightGray, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            /// ✅ 방문 횟수 & 날짜 (한 줄 | 구분자 포함, 우측 정렬)
                            Text(
                              "${review.visitCount}번째 방문 | ${_formatDate(review.date)}",
                              style: TextStyle(fontSize: 12, color: AppColors.lightGray),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// ✅ 리뷰 제목
                        if (review.title != null && review.title!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              review.title!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 8),

                        /// 리뷰 사진 (없을 경우 기본 회색 박스)
                        _buildReviewImage(review.imageUrl),

                        const SizedBox(height: 8),

                        /// 리뷰 내용 (최대 2줄)
                        Text(review.content, maxLines: 2, overflow: TextOverflow.ellipsis),

                        const SizedBox(height: 8),

                        /// 리뷰어가 먹은 메뉴 표시
                        if (review.menu.isNotEmpty)
                          _buildReviewMenu(review.menu),
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

  /// 리뷰 이미지 (없으면 회색 박스)
  Widget _buildReviewImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
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

  /// 리뷰에 포함된 메뉴 목록 표시
  Widget _buildReviewMenu(List<String> menu) {
    if (menu.isEmpty) return SizedBox.shrink();

    List<String> visibleMenu = menu.take(2).toList();
    int remaining = menu.length - 2;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...visibleMenu.map((item) =>
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray,
                ),
              ),
            )),

        /// "+N" 표시 (3개 이상 메뉴가 있을 경우)
        if (remaining > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              "+$remaining",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGray,
              ),
            ),
          ),
      ],
    );
  }

  /// 날짜 포맷 변경 (YYYY-MM-DD → MM.DD)
  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
