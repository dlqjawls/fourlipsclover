// lib/widgets/full_map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import 'kakao_map_native_view.dart';
import '../config/theme.dart';
import 'custom_switch.dart'; // CustomSwitch import 추가
import '../screens/label_example_screen.dart'; // 라벨 예제 화면 import

class FullMapScreen extends StatefulWidget {
  final String locationName;

  const FullMapScreen({Key? key, required this.locationName}) : super(key: key);

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.5,
        title: Text(
          "${widget.locationName} 지도",
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 18,
            color: AppColors.darkGray,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 라벨 예제 버튼 추가
          IconButton(
            icon: Icon(Icons.location_on, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          LabelExampleScreen(locationName: widget.locationName),
                ),
              );
            },
          ),
          // 추가 옵션 버튼
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.darkGray),
            onPressed: () {
              _showMapOptions(context, mapProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 전체 화면 지도
          Positioned.fill(
            child: KakaoMapNativeView(
              // Provider의 값을 사용하므로 여기서는 좌표를 직접 지정하지 않음
              listenToProvider: true,
              onMapCreated: () {
                // 지도가 생성되면 로딩 인디케이터 숨기기
                setState(() {});
              },
            ),
          ),

          // 로딩 인디케이터
          if (mapProvider.loadingState == MapLoadingState.loading)
            const Center(child: CircularProgressIndicator()),

          // 줌 컨트롤 버튼
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                // 줌 인 버튼
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomIn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkGray,
                  child: Icon(Icons.add),
                  onPressed: () {
                    mapProvider.setZoomLevel(mapProvider.zoomLevel + 1);
                  },
                ),
                SizedBox(height: 8),
                // 줌 아웃 버튼
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomOut',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkGray,
                  child: Icon(Icons.remove),
                  onPressed: () {
                    mapProvider.setZoomLevel(mapProvider.zoomLevel - 1);
                  },
                ),
              ],
            ),
          ),

          // 내 위치 버튼
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              child: Icon(Icons.my_location),
              onPressed: () {
                // 현재 위치 로직 구현
                // 실제로는 위치 권한 확인 및 현재 위치 가져오기 필요
                _getCurrentLocation(mapProvider);
              },
            ),
          ),
        ],
      ),
    );
  }


  // 지도 추가 옵션 표시 - CustomSwitch 사용
  void _showMapOptions(BuildContext context, MapProvider mapProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 라벨 표시 옵션 - CustomSwitch 사용
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '라벨 표시',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Anemone_air',
                            color: AppColors.darkGray,
                          ),
                        ),
                        CustomSwitch(
                          value: mapProvider.showLabels,
                          onChanged: (value) {
                            mapProvider.toggleLabels(value);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 현재 위치 가져오기 (실제 구현 필요)
  void _getCurrentLocation(MapProvider mapProvider) {
    // 실제 구현에서는 위치 권한 확인 및 GPS 활용 필요
    // 임시 구현: 기본 좌표로 설정
    mapProvider.setMapCenter(latitude: 35.1958, longitude: 126.8149);

    // 현재 위치 표시 활성화
    mapProvider.toggleCurrentLocation(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('현재 위치를 가져오는 중입니다...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
