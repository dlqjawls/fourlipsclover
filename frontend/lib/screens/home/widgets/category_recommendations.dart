import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class CategoryRecommendations extends StatelessWidget {
  const CategoryRecommendations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카테고리 데이터 (나중에 동적으로 불러오기)
    final categories = [
      {
        'name': '한식',
        'restaurants': [
          {'name': '갓잡은 생선구이', 'location': '서울 강남구', 'distance': 0.8, 'likes': 187},
          {'name': '청담 손칼국수', 'location': '서울 강남구', 'distance': 1.2, 'likes': 142},
          {'name': '한우 명가', 'location': '서울 강남구', 'distance': 0.5, 'likes': 231},
          {'name': '역전 할머니 맥주', 'location': '서울 강남구', 'distance': 1.7, 'likes': 176},
        ]
      },
      {
        'name': '카페',
        'restaurants': [
          {'name': '글래드 커피', 'location': '서울 강남구', 'distance': 0.3, 'likes': 156},
          {'name': '커피빈', 'location': '서울 강남구', 'distance': 0.6, 'likes': 122},
          {'name': '블루보틀', 'location': '서울 강남구', 'distance': 1.1, 'likes': 198},
          {'name': '테라로사', 'location': '서울 강남구', 'distance': 0.9, 'likes': 165},
        ]
      },
      {
        'name': '술집',
        'restaurants': [
          {'name': '강남포차', 'location': '서울 강남구', 'distance': 0.4, 'likes': 213},
          {'name': '이자카야 미코', 'location': '서울 강남구', 'distance': 0.7, 'likes': 189},
          {'name': '브루어리 304', 'location': '서울 강남구', 'distance': 1.5, 'likes': 201},
          {'name': '와인바 르', 'location': '서울 강남구', 'distance': 1.0, 'likes': 167},
        ]
      },
      {
        'name': '디저트',
        'restaurants': [
          {'name': '설빙', 'location': '서울 강남구', 'distance': 0.6, 'likes': 145},
          {'name': '생크림 케이크', 'location': '서울 강남구', 'distance': 0.9, 'likes': 162},
          {'name': '쿠키프렌즈', 'location': '서울 강남구', 'distance': 1.3, 'likes': 178},
          {'name': '베이크 치즈타르트', 'location': '서울 강남구', 'distance': 0.5, 'likes': 193},
        ]
      },
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // 해시태그 아이콘
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.verylightGray,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 카테고리명
                      Text(
                        '${category['name']} 추천',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  // 더보기 텍스트
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '더보기 >',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 카테고리별 맛집 리스트
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 8),
                itemCount: (category['restaurants'] as List).length,
                itemBuilder: (context, restaurantIndex) {
                  final restaurant = (category['restaurants'] as List)[restaurantIndex] as Map<String, dynamic>;
                  
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 맛집 이미지
                        Stack(
                          children: [
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                            ),
                            
                            // 거리 표시
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                      '${restaurant['distance'] ?? 0.0}km',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // 맛집 정보
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 이름과 좋아요 수
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant['name']?.toString() ?? '이름 없음',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: Colors.red.shade300,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        restaurant['likes']?.toString() ?? '0',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // 위치
                              const SizedBox(height: 4),
                              Text(
                                restaurant['location']?.toString() ?? '위치 정보 없음',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // 카테고리 간 구분선
            if (index < categories.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(
                  color: AppColors.verylightGray,
                  thickness: 1,
                ),
              ),
          ],
        );
      },
    );
  }
}