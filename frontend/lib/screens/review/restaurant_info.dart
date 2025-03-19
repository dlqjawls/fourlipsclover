import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RestaurantInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const RestaurantInfo({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

        /// 사진과 태그 사이 여백 (추가됨)
        const SizedBox(height: 12.0),

        /// 태그 목록 추가
        if (data['tags'] != null && data['tags'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: data['tags'].map<Widget>((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.mediumGray),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                );
              }).toList(),
            ),
          ),

        /// 태그와 가게 정보 사이 여백
        const SizedBox(height: 12.0),

        /// 가게 정보
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on, data['address']),
              _buildInfoRow(Icons.access_time, "영업시간: ${data['business_hours']}"),
              _buildInfoRow(Icons.phone, data['phone']),
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
