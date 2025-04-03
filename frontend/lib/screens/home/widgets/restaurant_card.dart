// lib/widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../review/restaurant_detail.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final String address; // 정보 표시 유지 여부 검토
  final String category; // 정보 표시 유지 여부 검토
  final String phone; // 정보 표시 유지 여부 검토
  final int likes;
  final List<String> hashtags;
  final double distance;
  final String kakaoPlaceId;
  // 추가될 필드들
  // final double sentimentScore; // AI 기반 리뷰 긍정/부정 점수 (0~100)
  // final int totalReviewLikes; // 리뷰들의 좋아요 수 총합
  // final String imageUrl; // 식당 이미지 URL

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.address,
    required this.category,
    required this.phone,
    this.likes = 0,
    this.hashtags = const [],
    this.distance = 0.0,
    required this.kakaoPlaceId,
    // 추가될 필드들
    // this.sentimentScore = 50.0,
    // this.totalReviewLikes = 0,
    // this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return GestureDetector(
      onTap: () {
        // 식당 상세 페이지로 이동
        print('식당 클릭: $name (ID: $kakaoPlaceId)');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RestaurantDetailScreen(restaurantId: kakaoPlaceId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 내용에 맞게 최소 높이로 조정
          children: [
            // 식당 이미지 (임시로 회색 박스)
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.lightGray,
                  // 이미지 추가 예정
                  // TODO: 이미지 URL이 추가되면 아래 코드 활성화
                  // child: imageUrl != null && imageUrl.isNotEmpty
                  //     ? Image.network(
                  //         imageUrl,
                  //         fit: BoxFit.cover,
                  //         errorBuilder: (context, error, stackTrace) {
                  //           return Center(
                  //             child: Icon(
                  //               Icons.restaurant,
                  //               color: AppColors.mediumGray,
                  //               size: 40,
                  //             ),
                  //           );
                  //         },
                  //       )
                  //     : Center(
                  //         child: Icon(
                  //           Icons.restaurant,
                  //           color: AppColors.mediumGray,
                  //           size: 40,
                  //         ),
                  //       ),
                ),

                // 거리 정보 (상단 왼쪽) - 미터 단위로 표시
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.lightGray,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          // 거리를 미터 단위로 표시 (km * 1000 = m)
                          '${(distance * 1000).round()} m',
                          style:
                              baseStyle
                                  ?.copyWith(color: Colors.white, fontSize: 10)
                                  .emphasized,
                        ),
                      ],
                    ),
                  ),
                ),

                // TODO: AI 긍정/부정 점수 표시 (상단 오른쪽)
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 8,
                //       vertical: 4,
                //     ),
                //     decoration: BoxDecoration(
                //       color: sentimentScore >= 50
                //           ? Colors.green.withOpacity(0.8)
                //           : Colors.red.withOpacity(0.8),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Text(
                //       '${sentimentScore.round()}점',
                //       style: baseStyle?.copyWith(
                //         color: Colors.white,
                //         fontSize: 10,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),

            // 식당 정보
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 식당 이름과 좋아요 수 한 줄에
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: baseStyle?.copyWith(fontSize: 15).emphasized,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 좋아요 수
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade300,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$likes',
                            style: baseStyle?.copyWith(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // TODO: 리뷰 좋아요 합계 표시
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.thumb_up_alt_outlined,
                  //       color: AppColors.primary,
                  //       size: 12,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '리뷰 좋아요 $totalReviewLikes',
                  //       style: baseStyle?.copyWith(
                  //         fontSize: 11,
                  //         color: AppColors.darkGray,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 6),

                  // 해시태그 (카테고리 기반 및 실제 해시태그)
                  if (hashtags.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 22,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            hashtags
                                .take(3)
                                .map((tag) => _buildHashtagChip(context, tag))
                                .toList(),
                      ),
                    ),

                  // TODO: 실제 해시태그가 추가되면 아래 코드 활성화
                  // if (realHashtags != null && realHashtags.isNotEmpty)
                  //   Container(
                  //     margin: const EdgeInsets.only(top: 6),
                  //     height: 22,
                  //     child: ListView(
                  //       scrollDirection: Axis.horizontal,
                  //       children: realHashtags
                  //           .take(3)
                  //           .map((tag) => _buildRealHashtagChip(context, tag))
                  //           .toList(),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 기반 해시태그 디자인 (회색)
  Widget _buildHashtagChip(BuildContext context, String tag) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.verylightGray, // 회색 배경
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: baseStyle?.copyWith(
          fontSize: 10,
          color: AppColors.mediumGray, // 회색 텍스트
        ),
      ),
    );
  }

  // TODO: 실제 해시태그 디자인 (강조 색상)
  // Widget _buildRealHashtagChip(BuildContext context, String tag) {
  //   final baseStyle = Theme.of(context).textTheme.bodyMedium;
  //   return Container(
  //     margin: const EdgeInsets.only(right: 6),
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //     decoration: BoxDecoration(
  //       color: AppColors.primary.withOpacity(0.1), // 메인 색상 배경 (연하게)
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Text(
  //       tag,
  //       style: baseStyle?.copyWith(
  //         fontSize: 10,
  //         color: AppColors.primary, // 메인 색상 텍스트
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
}
