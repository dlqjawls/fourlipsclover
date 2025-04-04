import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RestaurantInfo extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? imageUrl; // ✅ 대표 이미지 URL 전달받음

  const RestaurantInfo({
    Key? key,
    required this.data,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("RestaurantInfo Data: ${data['addressName']}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ 대표 이미지 (우선순위: imageUrl > data['image'] > 기본 이미지)
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.mediumGray,
            image: DecorationImage(
              image: _buildImageProvider(),
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// ✅ 태그 예쁘게 출력
        if (data['tags'] != null && data['tags'] is List)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: (data['tags'] as List<dynamic>).map<Widget>((tag) {
                final tagName = tag['tagName']?.toString().replaceAll(' ', '') ?? '';
                return Chip(
                  label: Text(
                    '#$tagName',
                    style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),

        /// ✅ 기본 정보
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on, data['addressName'] ?? "주소 정보 없음"),
              _buildInfoRow(Icons.access_time, "영업시간: ${data['business_hours'] ?? "정보 없음"}"),
              _buildInfoRow(
                Icons.phone,
                (data['phone'] != null && data['phone'].toString().trim().isNotEmpty)
                    ? data['phone']
                    : "전화 번호: 정보 없음",
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ 이미지 우선순위 설정
  ImageProvider _buildImageProvider() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!.startsWith("http")
          ? NetworkImage(imageUrl!)
          : AssetImage(imageUrl!) as ImageProvider;
    }

    final original = data['image'];
    if (original != null && original.isNotEmpty) {
      return NetworkImage(original);
    }

    // ✅ 기본 이미지 → rice.png 사용
    return const AssetImage("assets/images/rice.png");
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
              style: const TextStyle(color: AppColors.darkGray, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
