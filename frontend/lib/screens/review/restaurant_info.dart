import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RestaurantInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const RestaurantInfo({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ 디버깅: 주소 값 확인
    print("RestaurantInfo Data: ${data['addressName']}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 가게 이미지
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.mediumGray,
            image: (data['image'] != null && data['image'].isNotEmpty)
                ? DecorationImage(
              image: NetworkImage(data['image']),
              fit: BoxFit.cover,
            )
                : null,
          ),
        ),

        /// 태그 목록 추가
        if (data['tags'] != null && data['tags'] is List)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: (data['tags'] as List<dynamic>).map<Widget>((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.mediumGray),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag.toString(),
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                );
              }).toList(),
            ),
          ),

        /// 가게 정보
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on, data['addressName'] ?? "주소 정보 없음"),
              _buildInfoRow(Icons.access_time, "영업시간: ${data['business_hours'] ?? "정보 없음"}"),
              _buildInfoRow(Icons.phone, data['phone'] ?? "전화번호 없음"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mediumGray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.darkGray, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
