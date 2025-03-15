// map_preview.dart
import 'package:flutter/material.dart';

class MapPreview extends StatelessWidget {
  final String location;
  final VoidCallback onTapViewMap;

  const MapPreview({
    Key? key,
    required this.location,
    required this.onTapViewMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Stack(
        children: [
          // 여기에 카카오맵 구현 (현재는 더미 UI)
          Center(
            child: Text(
              "지도 로딩 중...",
              style: TextStyle(color: Colors.grey[600]),
            ),
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