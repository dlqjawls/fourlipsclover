// lib/screens/label_example_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/map_provider.dart';
import '../widgets/kakao_map_native_view.dart';
import '../config/theme.dart';
import '../services/kakao_map_service.dart';
// url_launcher 패키지가 필요합니다 (pubspec.yaml에 추가 필요)
// import 'package:url_launcher/url_launcher.dart';

// 가게 정보를 담는 모델 클래스
class RestaurantInfo {
  final String id;
  final String name;
  final String address;
  final String category;
  final String phone;
  final String placeUrl;
  final double latitude;
  final double longitude;

  RestaurantInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.phone,
    required this.placeUrl,
    required this.latitude,
    required this.longitude,
  });

  // API 응답 JSON에서 RestaurantInfo 객체 생성
  // 실제 API 연동 시 사용할 팩토리 메서드
  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['restaurantId'].toString(),
      name: json['placeName'],
      address: json['addressName'],
      category: json['category'] ?? '정보 없음',
      phone: json['phone'] ?? '정보 없음',
      placeUrl: json['placeUrl'] ?? '',
      latitude: double.parse(json['y'].toString()),
      longitude: double.parse(json['x'].toString()),
    );
  }
}

class LabelExampleScreen extends StatefulWidget {
  final String locationName;

  const LabelExampleScreen({Key? key, required this.locationName})
    : super(key: key);

  @override
  State<LabelExampleScreen> createState() => _LabelExampleScreenState();
}

class _LabelExampleScreenState extends State<LabelExampleScreen> {
  final List<MapLabel> _demoLabels = [];
  final Map<String, RestaurantInfo> _restaurantData = {};
  bool _mapInitialized = false;
  bool _isAddingLabels = false;

  // 인포윈도우 관련 상태
  String? _selectedLabelId;
  bool _showInfoWindow = false;
  // 인포윈도우의 위치를 조절하기 위한 오프셋
  double _infoWindowTopOffset = 150;

  @override
  void initState() {
    super.initState();
    _prepareDemoLabels();
    _prepareRestaurantData(); // 모의 가게 데이터 준비

    // 라벨 클릭 이벤트 리스너 설정
    // 주의: 실제 구현에서는 Native<->Flutter 통신 채널을 통해 설정해야 함
    // 아래 코드는 KakaoMapPlatform 클래스에 라벨 클릭 콜백을 설정하는 메서드가 있다고 가정
    // 실제 구현 시에는 해당 메서드를 구현해야 함
    _setupLabelClickListener();
  }

  // 라벨 클릭 리스너 설정 메서드
  void _setupLabelClickListener() {
    // 실제 구현 시 아래 형태로 Native<->Flutter 통신 설정 필요
    /*
    KakaoMapPlatform.setLabelClickListener((String labelId) {
      print('라벨 클릭됨: $labelId');
      _handleLabelClick(labelId);
    });
    */

    // 테스트 코드에서는 직접 호출하도록 구현
    // 실제 구현에서는 네이티브 이벤트로부터 호출되어야 함
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
        textSize: 24.0,
        imageAsset: 'clover',
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 1,
        isClickable: true,
      ),
    );

    _demoLabels.add(
      MapLabel(
        id: 'restaurant_2',
        latitude: 35.1962,
        longitude: 126.8152,
        text: '카페',
        textSize: 24.0,
        imageAsset: 'clover',
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 1,
        isClickable: true,
      ),
    );

    _demoLabels.add(
      MapLabel(
        id: 'restaurant_3',
        latitude: 35.1948,
        longitude: 126.8157,
        text: '분식집',
        textSize: 24.0,
        imageAsset: 'clover',
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 1,
        isClickable: true,
      ),
    );
  }

  // 모의 가게 데이터 준비 메서드
  // 실제 구현 시에는 API에서 데이터를 가져와야 함
  void _prepareRestaurantData() {
    // 모의 데이터 구성 - 실제 API 연동 시 대체 필요
    _restaurantData['restaurant_1'] = RestaurantInfo(
      id: 'restaurant_1',
      name: '맛있는 식당',
      address: '광주 광산구 수완동 123-4',
      category: '음식점 > 한식 > 육류, 고기',
      phone: '062-123-4567',
      placeUrl: 'http://place.map.kakao.com/12345678',
      latitude: 35.1954,
      longitude: 126.8145,
    );

    _restaurantData['restaurant_2'] = RestaurantInfo(
      id: 'restaurant_2',
      name: '카페',
      address: '광주 광산구 수완동 456-7',
      category: '음식점 > 카페',
      phone: '062-234-5678',
      placeUrl: 'http://place.map.kakao.com/23456789',
      latitude: 35.1962,
      longitude: 126.8152,
    );

    _restaurantData['restaurant_3'] = RestaurantInfo(
      id: 'restaurant_3',
      name: '분식집',
      address: '광주 광산구 수완동 789-0',
      category: '음식점 > 분식',
      phone: '062-345-6789',
      placeUrl: 'http://place.map.kakao.com/34567890',
      latitude: 35.1948,
      longitude: 126.8157,
    );
  }

  // API에서 가게 정보 가져오기 (실제 구현 시 사용)
  // API 연동 시 사용할 메서드
  /*
  Future<List<RestaurantInfo>> _fetchRestaurantsFromApi(double latitude, double longitude) async {
    try {
      // 실제 API 호출 코드
      final response = await http.get(
        Uri.parse('https://fourlipsclover.duckdns.org/api/restaurant/nearby?latitude=$latitude&longitude=$longitude'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => RestaurantInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }
  */

  // 라벨 클릭 처리 메서드
  void _handleLabelClick(String labelId) {
    print('라벨 클릭 처리: $labelId');

    // 라벨 ID에 해당하는 가게 정보가 있는지 확인
    if (_restaurantData.containsKey(labelId)) {
      setState(() {
        _selectedLabelId = labelId;
      });

      // 선택된 라벨이 지도 중앙에 오도록 지도 이동
      final restaurant = _restaurantData[labelId]!;
      KakaoMapPlatform.setMapCenter(
        latitude: restaurant.latitude,
        longitude: restaurant.longitude,
        zoomLevel: 16, // 적절한 줌 레벨 설정
      );

      // 바텀 시트 표시
      _showRestaurantBottomSheet(context, restaurant);
    } else {
      print('해당 라벨의 정보를 찾을 수 없음: $labelId');
    }
  }

  // 바텀 시트 표시 메서드
  void _showRestaurantBottomSheet(
    BuildContext context,
    RestaurantInfo restaurant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 높이 조절 가능하게 설정
      backgroundColor: Colors.transparent, // 투명 배경
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        // 화면 높이의 1/3 ~ 1/4 정도의 크기로 설정
        return FractionallySizedBox(
          heightFactor: 0.3, // 화면 높이의 30%
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: RestaurantBottomSheet(restaurantInfo: restaurant),
          ),
        );
      },
    );
  }

  // _addLabelsToMap 메서드
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
        textSize: 16.0,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 0,
        isClickable: true,
      );

      // 랜덤 라벨에 대한 가게 정보도 생성
      _restaurantData[labelId] = RestaurantInfo(
        id: labelId,
        name: '랜덤 가게 ${random.nextInt(100)}',
        address: '광주 광산구 어딘가 ${random.nextInt(999)}',
        category: '랜덤 카테고리',
        phone:
            '062-${random.nextInt(900) + 100}-${random.nextInt(9000) + 1000}',
        placeUrl:
            'http://place.map.kakao.com/${random.nextInt(90000000) + 10000000}',
        latitude: newLat,
        longitude: newLng,
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

      // 인포윈도우 닫기
      void _closeInfoWindow() {
        setState(() {
          _showInfoWindow = false;
          _selectedLabelId = null;
        });
      }

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

  // 테스트용 라벨 클릭 시뮬레이션 (실제 구현에서는 Native에서 호출됨)
  void _simulateLabelClick(String labelId) {
    _handleLabelClick(labelId);
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

                  // 테스트용 인포윈도우 버튼 (실제 구현 시 제거 필요)
                  // 이 부분은 테스트를 위한 것으로, 실제 구현 시에는 네이티브에서 라벨 클릭 이벤트를 받아서 처리해야 함
                  SizedBox(height: 12),
                  Text(
                    '테스트용 라벨 클릭 시뮬레이션',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _restaurantData.entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _simulateLabelClick(entry.key),
                                    child: Text(
                                      entry.value.name,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
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

// 바텀 시트 위젯
class RestaurantBottomSheet extends StatelessWidget {
  final RestaurantInfo restaurantInfo;

  const RestaurantBottomSheet({Key? key, required this.restaurantInfo})
    : super(key: key);

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
            restaurantInfo.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          // 가게 정보
          _buildInfoRow(Icons.location_on, restaurantInfo.address),
          _buildInfoRow(Icons.category, restaurantInfo.category),
          _buildInfoRow(Icons.phone, restaurantInfo.phone),
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
                  // 길찾기 기능 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('길찾기 기능은 실제 구현 시 추가 예정')),
                  );
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
                        'url_launcher 패키지로 ${restaurantInfo.placeUrl} 열기',
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
