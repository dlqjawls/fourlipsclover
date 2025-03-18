// lib/widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'kakao_map_native_view.dart';
import '../config/theme.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(8),
          // Add a clip to prevent the map from showing outside rounded corners
          color: AppColors.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 로딩 메시지
              Center(
                child: Text(
                  "$location 지역 지도 로딩 중...",
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    color: AppColors.mediumGray,
                  ),
                ),
              ),

              // 카카오맵 뷰 적용 - 인터랙션 방지를 위한 AbsorbPointer 추가
              AbsorbPointer(
                absorbing: true, // 모든 터치 이벤트 차단
                child: KakaoMapNativeView(
                  latitude: latitude,
                  longitude: longitude,
                  zoomLevel: 3,
                  // gestureEnabled 속성은 KakaoMapNativeView에 없으므로 제거
                ),
              ),

              // 투명 오버레이 - 모든 맵 제스처 블록을 확실히 하기 위함
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // 빈 콜백으로 탭 이벤트 소비
                  child: Container(color: Colors.transparent),
                ),
              ),

              // 지도로 보기 버튼
              Positioned(
                right: 8,
                bottom: 4,
                child: ElevatedButton(
                  onPressed: onTapViewMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.darkGray,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size(10, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.mediumGray,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "지도로 보기",
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
