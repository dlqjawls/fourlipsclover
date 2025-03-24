// lib/screens/label_example_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/map_provider.dart';
import '../widgets/kakao_map_native_view.dart';
import '../config/theme.dart';
import '../services/kakao_map_service.dart';

class LabelExampleScreen extends StatefulWidget {
  final String locationName;

  const LabelExampleScreen({Key? key, required this.locationName})
    : super(key: key);

  @override
  State<LabelExampleScreen> createState() => _LabelExampleScreenState();
}

class _LabelExampleScreenState extends State<LabelExampleScreen> {
  final List<MapLabel> _demoLabels = [];
  bool _mapInitialized = false;
  bool _isAddingLabels = false;

  @override
  void initState() {
    super.initState();
    _prepareDemoLabels();
  }

  // 데모용 라벨 데이터 준비
  void _prepareDemoLabels() {
    // 맛집 라벨 예시
    _demoLabels.add(
      MapLabel(
        id: 'restaurant_1',
        latitude: 35.1954,
        longitude: 126.8145,
        text: '맛있는 식당',
        textSize: 20.0,
        // textColor: Colors.black,
        // backgroundColor: Colors.white.withOpacity(0.8),
        imageAsset: 'clover',
        alpha: 1.0, // 이 값도 추가하는 것이 좋음
        rotation: 0.0, // 이 값도 추가하는 것이 좋음
        zIndex: 1, // 이 값도 추가하는 것이 좋음
        isClickable: true,
      ),
    );

    _demoLabels.add(
      MapLabel(
        id: 'restaurant_2',
        latitude: 35.1962,
        longitude: 126.8152,
        text: '카페',
        textSize: 20.0,
        // textColor: Colors.black,
        // backgroundColor: Colors.white.withOpacity(0.8),
        imageAsset: 'clover',
        alpha: 1.0, // 이 값도 추가하는 것이 좋음
        rotation: 0.0, // 이 값도 추가하는 것이 좋음
        zIndex: 1, // 이 값도 추가하는 것이 좋음
        isClickable: true,
      ),
    );

    _demoLabels.add(
      MapLabel(
        id: 'restaurant_3',
        latitude: 35.1948,
        longitude: 126.8157,
        text: '분식집',
        // textColor: Colors.black,  // 현재는 주석 처리된 상태
        textSize: 20.0, // 이 값은 추가해야 함
        // backgroundColor: Colors.white.withOpacity(0.8),  // 현재는 주석 처리된 상태
        imageAsset: 'clover',
        alpha: 1.0, // 이 값도 추가하는 것이 좋음
        rotation: 0.0, // 이 값도 추가하는 것이 좋음
        zIndex: 1, // 이 값도 추가하는 것이 좋음
        isClickable: true,
      ),
    );
  }

  // _addLabelsToMap 메서드 수정
  Future<void> _addLabelsToMap() async {
    setState(() {
      _isAddingLabels = true;
    });

    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // 현재 지도 상태 저장
    final currentLat = mapProvider.centerLatitude;
    final currentLng = mapProvider.centerLongitude;
    final currentZoom = mapProvider.zoomLevel;

    // 기존 라벨 모두 제거
    await KakaoMapPlatform.clearLabels();
    mapProvider.clearLabels();

    // 새 라벨 추가
    for (final label in _demoLabels) {
      try {
        // 네이티브에 라벨 추가
        await KakaoMapPlatform.addLabel(
          labelId: label.id,
          latitude: label.latitude,
          longitude: label.longitude,
          text: label.text,
          imageAsset: label.imageAsset,
          textSize: label.textSize,
          alpha: label.alpha ?? 1.0,
          rotation: label.rotation ?? 0.0,
          zIndex: label.zIndex,
          isClickable: label.isClickable,
        );

        // Provider에도 추가
        mapProvider.addLabel(
          id: label.id,
          latitude: label.latitude,
          longitude: label.longitude,
          text: label.text,
          imageAsset: label.imageAsset,
          textSize: label.textSize,
          alpha: label.alpha ?? 1.0,
          rotation: label.rotation ?? 0.0,
          zIndex: label.zIndex,
          isClickable: label.isClickable,
        );

        // 각 라벨 추가 사이에 짧은 딜레이 (UI에서 더 잘 보이도록)
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        print('라벨 추가 오류: $e');
      }
    }

    // 라벨 추가 후 원래 지도 상태로 복원
    // 만약 위에서 KakaoMapPlugin.kt를 수정했다면 이 부분은 필요 없을 수도 있지만
    // 보험으로 추가하는 것이 좋습니다
    await KakaoMapPlatform.setMapCenter(
      latitude: currentLat,
      longitude: currentLng,
      zoomLevel: currentZoom,
    );

    setState(() {
      _isAddingLabels = false;
    });
  }

  // 랜덤 위치에 라벨 추가
  Future<void> _addRandomLabel() async {
    // 현재 지도 중심에서 약간 떨어진 랜덤 위치 계산
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final random = math.Random();

    // 현재 중심에서 약간의 오프셋 (약 ±0.005도, 약 500m 범위)
    final latOffset = (random.nextDouble() - 0.5) * 0.01;
    final lngOffset = (random.nextDouble() - 0.5) * 0.01;

    // 새 위치 계산
    final newLat = mapProvider.centerLatitude + latOffset;
    final newLng = mapProvider.centerLongitude + lngOffset;

    // 랜덤 색상 생성
    final color = Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      1.0,
    );

    // 라벨 ID 생성
    final labelId = 'random_label_${DateTime.now().millisecondsSinceEpoch}';

    // 라벨 추가
    try {
      // 네이티브에 라벨 추가
      await KakaoMapPlatform.addLabel(
        labelId: labelId,
        latitude: newLat,
        longitude: newLng,
        text: '랜덤 라벨',
        // textColor: Colors.white,
        // backgroundColor: color,
        textSize: 16.0,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 0,
        isClickable: true,
      );

      // Provider에도 추가
      mapProvider.addLabel(
        id: labelId,
        latitude: newLat,
        longitude: newLng,
        text: '랜덤 라벨',
        // textColor: Colors.white,
        // backgroundColor: color,
        textSize: 16.0,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 0,
        isClickable: true,
      );

      // 성공 메시지
    } catch (e) {
      print('랜덤 라벨 추가 오류: $e');
    }
  }

  // 라벨 모두 제거
  Future<void> _clearAllLabels() async {
    try {
      await KakaoMapPlatform.clearLabels();

      // Provider의 라벨도 제거
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.clearLabels();

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('모든 라벨이 제거되었습니다')));
      }
    } catch (e) {
      print('라벨 제거 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.5,
        title: Text(
          "${widget.locationName} - 라벨 예제",
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
      ),
      body: Stack(
        children: [
          // 전체 화면 지도
          Positioned.fill(
            child: KakaoMapNativeView(
              listenToProvider: true,
              onMapCreated: () {
                setState(() {
                  _mapInitialized = true;
                });
              },
            ),
          ),

          // 로딩 인디케이터
          if (mapProvider.loadingState == MapLoadingState.loading)
            const Center(child: CircularProgressIndicator()),

          // 라벨 추가중 인디케이터
          if (_isAddingLabels)
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('라벨 추가 중...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // 하단 컨트롤 패널
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '라벨 컨트롤',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add_location),
                        label: Text('샘플 라벨'),
                        onPressed:
                            _mapInitialized
                                ? () async {
                                  // 현재 지도 상태 저장
                                  final mapProvider = Provider.of<MapProvider>(
                                    context,
                                    listen: false,
                                  );
                                  final currentLat = mapProvider.centerLatitude;
                                  final currentLng =
                                      mapProvider.centerLongitude;
                                  final currentZoom = mapProvider.zoomLevel;

                                  // 라벨 추가 작업 수행
                                  await _addLabelsToMap();

                                  // 약간의 지연 후 원래 위치로 강제 복귀
                                  await Future.delayed(
                                    Duration(milliseconds: 300),
                                  );
                                  await KakaoMapPlatform.setMapCenter(
                                    latitude: currentLat,
                                    longitude: currentLng,
                                    zoomLevel: currentZoom,
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGray,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.shuffle),
                        label: Text('랜덤 라벨'),
                        onPressed: _mapInitialized ? _addRandomLabel : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text('모두 제거'),
                        onPressed: _mapInitialized ? _clearAllLabels : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '현재 라벨 수: ${mapProvider.labels.length}',
                    style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
