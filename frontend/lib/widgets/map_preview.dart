// lib/widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import 'kakao_map_native_view.dart';
import '../config/theme.dart';
import 'package:frontend/widgets/full_map_screen.dart';

class MapPreview extends StatelessWidget {
  final String location;
  final VoidCallback? onTapViewMap; // nullable로 변경
  final double? latitude;
  final double? longitude;
  final int? zoomLevel;

  const MapPreview({
    Key? key,
    required this.location,
    this.onTapViewMap, // 선택적으로 변경
    this.latitude,
    this.longitude,
    this.zoomLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider 사용
    final mapProvider = Provider.of<MapProvider>(context);

    // 라벨이 있는지 확인
    print("MapPreview - 라벨 수: ${mapProvider.labels.length}");

    // 위도/경도 값 결정 (위젯 속성 → Provider)
    final lat = latitude ?? mapProvider.centerLatitude;
    final lng = longitude ?? mapProvider.centerLongitude;
    final zoom = zoomLevel ?? mapProvider.zoomLevel;

    // 맵 프리뷰에 들어오면 Provider 값 업데이트
    // 하지만 위젯 속성이 제공된 경우에만
    if (latitude != null && longitude != null) {
      // build에서 호출 (하지만 실제 상태가 변경될 때만 업데이트)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mapProvider.centerLatitude != lat ||
            mapProvider.centerLongitude != lng ||
            mapProvider.zoomLevel != zoom) {
          mapProvider.setMapCenter(
            latitude: lat,
            longitude: lng,
            zoomLevel: zoom,
          );
        }
      });
    }

    // 전체 지도 화면으로 이동하는 함수
    void _navigateToFullMap() {
      print("지도로 보기 버튼 클릭됨");
      Navigator.pushNamed(
        context,
        '/full_map',
        arguments: {'locationName': location},
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 로딩 메시지 - Provider 상태에 따라 표시
              if (mapProvider.loadingState == MapLoadingState.loading)
                Center(
                  child: Text(
                    "$location 지역 지도 로딩 중...",
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),

              // 에러 메시지 - Provider 상태에 따라 표시
              if (mapProvider.loadingState == MapLoadingState.failure)
                Center(
                  child: Text(
                    "지도 로딩 실패: ${mapProvider.lastError ?? '알 수 없는 오류'}",
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // 카카오맵 뷰 적용 - 인터랙션 방지를 위한 AbsorbPointer 대신 IgnorePointer ? ? 
              IgnorePointer(
                child: KakaoMapNativeView(
                  latitude: latitude,
                  longitude: longitude,
                  zoomLevel: zoomLevel,
                  listenToProvider: true,
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
                  onPressed: _navigateToFullMap, // 네비게이션 함수 연결
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
