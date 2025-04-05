// lib/screens/map/widgets/restaurant_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../models/restaurant_model.dart';
import '../../../config/theme.dart';

class RestaurantBottomSheet extends StatelessWidget {
  final RestaurantResponse restaurant;
  final Function(String) onRouteButtonPressed;

  const RestaurantBottomSheet({
    Key? key,
    required this.restaurant,
    required this.onRouteButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 바텀 시트 핸들 (회색 줄)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 가게 이름
          Text(
            restaurant.placeName ?? '이름 없음',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          // 가게 정보
          _buildInfoRow(Icons.location_on, restaurant.addressName ?? '주소 정보가 없습니다'),
          _buildInfoRow(Icons.category, restaurant.category ?? '카테고리 정보가 없습니다'),
          _buildInfoRow(Icons.phone, restaurant.phone ?? '전화번호 정보가 없습니다'),
          SizedBox(height: 16),
          // 버튼 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.directions,
                '길찾기',
                Colors.blue,
                () {
                  // 길찾기 기능 호출
                  Navigator.pop(context); // 바텀 시트 닫기
                  onRouteButtonPressed(restaurant.kakaoPlaceId);
                },
              ),
              _buildActionButton(
                context,
                Icons.bookmark_border,
                '저장',
                Colors.orange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('저장 기능은 실제 구현 시 추가 예정')),
                  );
                },
              ),
              _buildActionButton(
                context,
                Icons.launch,
                '상세정보',
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'url_launcher 패키지로 ${restaurant.placeUrl} 열기',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}