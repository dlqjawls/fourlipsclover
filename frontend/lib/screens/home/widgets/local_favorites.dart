import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';

class LocalFavorites extends StatelessWidget {
  const LocalFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    // 샘플 식당 데이터 (이름, 좋아요 수, 해시태그, 거리)
    final restaurants = [
      {
        'name': '김쿨라멘',
        'likes': 128,
        'hashtags': ['#라멘', '#일식', '#혼밥'],
        'distance': 0.3,
      },
      {
        'name': '시마카세',
        'likes': 256,
        'hashtags': ['#초밥', '#일식', '#데이트코스'],
        'distance': 0.5,
      },
      {
        'name': '멕시카나',
        'likes': 196,
        'hashtags': ['#멕시코', '#양식', '#가성비맛집'],
        'distance': 0.7,
      },
      {
        'name': '황제반점',
        'likes': 312,
        'hashtags': ['#중식', '#짜장면', '#가족식사'],
        'distance': 1.2,
      },
      {
        'name': '수유리우동',
        'likes': 245,
        'hashtags': ['#우동', '#일식', '#혼밥'],
        'distance': 1.5,
      },
      {
        'name': '맛있는고깃집',
        'likes': 278,
        'hashtags': ['#한식', '#고기', '#회식'],
        'distance': 1.8,
      },
      {
        'name': '초밥왕',
        'likes': 189,
        'hashtags': ['#초밥', '#일식', '#인스타감성'],
        'distance': 2.1,
      },
      {
        'name': '파스타하우스',
        'likes': 221,
        'hashtags': ['#파스타', '#양식', '#데이트코스'],
        'distance': 2.4,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 구분선
        const Divider(
          thickness: 10.0,
          height: 1,
          color: AppColors.verylightGray,
        ),

        // 제목 영역 - 디자인 개선
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 좌측 - 내 주변 + 아이콘
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 주변',
                        style: baseStyle?.copyWith(fontSize: 18).emphasized,
                      ),
                      Text(
                        '현지인이 선호하는 맛집',
                        style: baseStyle?.copyWith(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 우측 - 지역 변경 버튼
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  backgroundColor: AppColors.verylightGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: AppColors.darkGray, size: 14),
                    const SizedBox(width: 4),
                    Text('지역 변경', style: baseStyle?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2x2 그리드 형태로 식당 표시 (페이징 가능)
        SizedBox(
          height: 500,
          child: PageView.builder(
            itemCount: (restaurants.length / 4).ceil(), // 4개씩 페이지 계산
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 4;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.78, // 비율 조정
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: List.generate(
                    4.clamp(0, restaurants.length - startIndex),
                    (index) {
                      final itemIndex = startIndex + index;
                      if (itemIndex >= restaurants.length)
                        return const SizedBox();

                      final restaurant = restaurants[itemIndex];

                      return RestaurantCard(
                        name: restaurant['name'].toString(),
                        likes: restaurant['likes'] as int,
                        hashtags: List<String>.from(
                          restaurant['hashtags'] as List,
                        ),
                        distance: restaurant['distance'] as double,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // 자세히 보기 버튼 - 회색으로 변경
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkGray,
                side: BorderSide(color: AppColors.mediumGray),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('자세히 보기', style: baseStyle?.copyWith(fontSize: 14)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 수정된 식당 카드 위젯
class RestaurantCard extends StatelessWidget {
  final String name;
  final int likes;
  final List<String> hashtags;
  final double distance;

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.likes,
    required this.hashtags,
    this.distance = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Container(
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식당 이미지 (임시로 회색 박스)
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: AppColors.lightGray,
              ),

              // 거리 정보 (상단 왼쪽) - 지도 아이콘으로 변경, 반투명 회색 배경
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2), // 반투명 회색
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
                        '${distance.toStringAsFixed(1)}km',
                        style:
                            baseStyle
                                ?.copyWith(color: Colors.white, fontSize: 10)
                                .emphasized,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 식당 정보 - 컴팩트하고 세련되게
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
                    // 좋아요 수 (아이콘과 숫자만)
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

                // 해시태그 (회색 스타일로 변경)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 22, // 고정 높이로 공간 최소화
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        hashtags
                            .take(3)
                            .map((tag) => _buildHashtagChip(context, tag))
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 회색 해시태그 디자인
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
}
