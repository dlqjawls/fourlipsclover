// lib/widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'kakao_map_native_view.dart';

class MapPreview extends StatelessWidget {
  final String location;
  final VoidCallback onTapViewMap;
  final double latitude;
  final double longitude;

  const MapPreview({
    Key? key,
    required this.location,
    required this.onTapViewMap,
    this.latitude = 35.1958,
    this.longitude = 126.8149,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Stack(
        children: [
          // 로딩 메시지
          Center(
            child: Text(
              "$location 지역 지도 로딩 중...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          
          // 카카오맵 뷰 적용
          KakaoMapNativeView(
            latitude: latitude, 
            longitude: longitude,
            zoomLevel: 3,
          ),
          
          // 지도로 보기 버튼
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: onTapViewMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("지도로 보기"),
            ),
          ),
        ],
      ),
    );
  }
}