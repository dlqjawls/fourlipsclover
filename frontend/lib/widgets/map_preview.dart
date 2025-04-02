// lib/widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import 'kakao_map_native_view.dart';
import '../config/theme.dart';
import 'package:frontend/widgets/full_map_screen.dart';

class MapPreview extends StatefulWidget {
  final String location;
  final VoidCallback? onTapViewMap;
  final double? latitude;
  final double? longitude;
  final int? zoomLevel;

  const MapPreview({
    Key? key,
    required this.location,
    this.onTapViewMap,
    this.latitude,
    this.longitude,
    this.zoomLevel,
  }) : super(key: key);

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  @override
  void initState() {
    super.initState();
    _updateMapCenter();
  }

  @override
  void didUpdateWidget(MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 위젯 속성이 변경되었을 때만 업데이트
    if (oldWidget.latitude != widget.latitude || 
        oldWidget.longitude != widget.longitude ||
        oldWidget.zoomLevel != widget.zoomLevel) {
      _updateMapCenter();
    }
  }

  // 지도 중심 위치 업데이트 - 빌드 사이클 밖에서 처리
  void _updateMapCenter() {
    if (widget.latitude != null && widget.longitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        
        // 현재 값과 다를 때만 업데이트 (불필요한 상태 변경 방지)
        if (mapProvider.centerLatitude != widget.latitude ||
            mapProvider.centerLongitude != widget.longitude ||
            (widget.zoomLevel != null && mapProvider.zoomLevel != widget.zoomLevel)) {
          
          mapProvider.setMapCenter(
            latitude: widget.latitude!,
            longitude: widget.longitude!,
            zoomLevel: widget.zoomLevel,
          );
        }
      });
    }
  }

  // 전체 지도 화면으로 이동하는 함수
  void _navigateToFullMap() {
    Navigator.pushNamed(
      context,
      '/full_map',
      arguments: {'locationName': widget.location},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider에서 읽기만 하고, 쓰기는 하지 않음
    final mapProvider = Provider.of<MapProvider>(context);

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
                    "${widget.location} 지역 지도 로딩 중...",
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

              // 카카오맵 뷰 적용 - 인터랙션 방지를 위한 IgnorePointer
              IgnorePointer(
                child: KakaoMapNativeView(
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  zoomLevel: widget.zoomLevel,
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
                  onPressed: widget.onTapViewMap ?? _navigateToFullMap,
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