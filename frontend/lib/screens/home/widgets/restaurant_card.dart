import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../review/restaurant_detail.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>>? tags;
  final double distance;
  final String kakaoPlaceId;
  final List<String>? images;

  const RestaurantCard({
    Key? key,
    required this.name,
    this.tags,
    required this.distance,
    required this.kakaoPlaceId,
    this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카드 사이즈 계산 - 정사각형 이미지
    final cardWidth =
        MediaQuery.of(context).size.width / 2 - 24; // 2열 그리드에서 좌우 여백 고려

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RestaurantDetailScreen(restaurantId: kakaoPlaceId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지만 있는 카드 (그림자와 라운드 처리)
          Container(
            width: cardWidth,
            height: cardWidth, // 정사각형
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: cardWidth,
                    height: cardWidth,
                    child:
                        images != null && images!.isNotEmpty
                            ? Image.network(
                              images!.first,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _buildDefaultImage(),
                            )
                            : _buildDefaultImage(),
                  ),
                ),

                // 거리 표시 (상단 왼쪽)
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
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distance < 1
                              ? '${(distance * 1000).round()} m'
                              : '${distance.toStringAsFixed(1)} km',
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
          ),

          // 카드 아래에 식당 정보 표시
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 식당 이름
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // 태그 (박스 없이 텍스트만)
                if (tags != null && tags!.isNotEmpty)
                  Text(
                    _getFormattedTags(),
                    style: TextStyle(fontSize: 11, color: AppColors.mediumGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // frequency 높은 순서로 정렬, 같으면 avgConfidence 높은 순으로 정렬하여 텍스트로 변환
  String _getFormattedTags() {
    if (tags == null || tags!.isEmpty) {
      return '';
    }

    // 태그를 frequency 내림차순, 동점이면 avgConfidence 내림차순으로 정렬
    final sortedTags = List<Map<String, dynamic>>.from(tags!)..sort((a, b) {
      // frequency 비교 (높은 순)
      final aFreq = a['frequency'] as int?;
      final bFreq = b['frequency'] as int?;

      if (aFreq != bFreq) {
        if (aFreq == null) return 1;
        if (bFreq == null) return -1;
        return bFreq.compareTo(aFreq); // 내림차순 (높은 값이 먼저)
      }

      // frequency가 같으면 avgConfidence로 비교 (높은 순)
      final aConf = a['avgConfidence'] as num?;
      final bConf = b['avgConfidence'] as num?;
      if (aConf == null && bConf == null) return 0;
      if (aConf == null) return 1;
      if (bConf == null) return -1;
      return bConf.compareTo(aConf); // 내림차순
    });

    // 상위 3개 태그만 사용하여 "#태그1 #태그2 #태그3" 형식으로 반환
    return sortedTags
        .take(3)
        .map((tag) => '#${tag['tagName'] ?? ''}')
        .join(' ');
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.lightGray,
      child: Center(
        child: Image.asset(
          'assets/images/default_image.png',
          fit: BoxFit.cover, // 카드를 꽉 채우도록 변경
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
