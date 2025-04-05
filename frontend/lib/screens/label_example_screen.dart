// lib/screens/label_example_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:async'; // StreamSubscription을 위한 import
import '../providers/map_provider.dart';
import '../widgets/kakao_map_native_view.dart';
import '../config/theme.dart';
import '../services/kakao_map_service.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보를 위한 패키지
import 'map/widgets/route_summary_modal.dart';
import 'map/widgets/route_search_panel.dart';
import 'package:flutter/services.dart'; //SystemOvelayStyle 사용을 위해
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
  double _infoWindowTopOffset = 150;

  // 위치 추적 관련 변수
  String _userLocationLabelId = 'user_location_marker';
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLocationTracking = false;
  Position? _currentPosition;

  //오버레이
  OverlayEntry? _overlayEntry;

  //길찾기 패널 표시 여부부
  bool _showRoutePanel = false;

  String? _lastOriginId;
  String? _lastDestinationId;

  @override
  void initState() {
    super.initState();
    _prepareDemoLabels();
    _prepareRestaurantData(); // 모의 가게 데이터 준비

    // 라벨 클릭 이벤트 리스너 설정
    _setupLabelClickListener();

    // 지도 생성 후 현재 위치 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapInitialized) {
        _moveToCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _stopLocationTracking(); // 위치 추적 중지
    super.dispose();
  }

  @override
  void didUpdateWidget(LabelExampleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndSearchRoute();
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

  // 현재 위치 가져오기
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.')),
      );
      return null;
    }

    // 권한 체크
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('위치 권한이 거부되었습니다.')));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.')),
      );
      return null;
    }

    // 현재 위치 가져오기
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      print('위치 가져오기 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('현재 위치를 가져오는데 실패했습니다.')));
      return null;
    }
  }

  // 현재 위치 마커 추가
  Future<void> _addUserLocationMarker(double latitude, double longitude) async {
    try {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      bool markerExists = mapProvider.labels.any(
        (label) => label.id == _userLocationLabelId,
      );

      // Provider에서만 제거 (이미 있는 경우)
      if (markerExists) {
        mapProvider.removeLabel(_userLocationLabelId);
      }

      // 사용자 위치 마커 추가
      await KakaoMapPlatform.addLabel(
        labelId: _userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
        text: null, // 텍스트 없음
        imageAsset: 'swallow', // 현재 위치 마커 이미지 - 네잎클로버 이미지 이름에 맞게 변경
        textSize: null,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 10, // 다른 마커보다 위에 표시되도록 높은 zIndex 설정
        isClickable: false, // 클릭 불가능하게 설정
      );

      // Provider에도 추가
      mapProvider.addLabel(
        id: _userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
        text: null,
        imageAsset: 'swallow', // 네잎클로버 이미지 이름에 맞게 변경
        textSize: null,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 10,
        isClickable: false,
      );

      print('사용자 위치 마커 추가됨: ($latitude, $longitude)');
    } catch (e) {
      print('사용자 위치 마커 추가 오류: $e');
    }
  }

  // 위치 추적 시작
  void _startLocationTracking() {
    if (_isLocationTracking) return;

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터마다 업데이트
      ),
    ).listen((Position position) {
      // 위치가 업데이트될 때마다 호출됨
      _updateUserLocationMarker(position.latitude, position.longitude);
      _currentPosition = position;
    });

    _isLocationTracking = true;
    print('위치 추적 시작됨');
  }

  // 위치 추적 중지
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isLocationTracking = false;
    print('위치 추적 중지됨');
  }

  // 사용자 위치 마커 업데이트 (수정)
  Future<void> _updateUserLocationMarker(
    double latitude,
    double longitude,
  ) async {
    try {
      // 위치 마커 업데이트
      await KakaoMapPlatform.updateLabelPosition(
        labelId: _userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
      );

      // Provider 업데이트
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.updateLabelPosition(
        _userLocationLabelId,
        latitude,
        longitude,
      );

      print('사용자 위치 마커 업데이트됨: ($latitude, $longitude)');
    } catch (e) {
      print('사용자 위치 마커 업데이트 오류: $e');
    }
  }

  // 현재 위치로 이동 (수정)
  Future<void> _moveToCurrentLocation() async {
    Position? position = await _getCurrentLocation();
    if (position != null) {
      // 사용자 위치로 지도 이동
      await KakaoMapPlatform.setMapCenter(
        latitude: position.latitude,
        longitude: position.longitude,
        zoomLevel: 16, // 적절한 줌 레벨
      );

      // 사용자 위치 마커 표시
      await _addUserLocationMarker(position.latitude, position.longitude);

      // 위치 추적 시작 (아직 시작되지 않았다면)
      if (!_isLocationTracking) {
        _startLocationTracking();
      }
    }
  }

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
            child: RestaurantBottomSheet(
              restaurantInfo: restaurant,
              screenState: this,
            ),
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

  // 인포윈도우 닫기 메서드 (바텀 시트에서는 필요 없지만 호환성을 위해 유지)
  void _closeInfoWindow() {
    setState(() {
      _showInfoWindow = false;
      _selectedLabelId = null;
    });
  }

  // 라벨 모두 제거
  Future<void> _clearAllLabels() async {
    try {
      await KakaoMapPlatform.clearLabels();

      // Provider의 라벨도 제거
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.clearLabels();

      // 인포윈도우 닫기
      _closeInfoWindow();

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

  // 테스트용 경로 데이터 생성
  List<Map<String, double>> _generateTestRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    List<Map<String, double>> route = [];

    // 시작점
    route.add({'latitude': startLat, 'longitude': startLng});

    // 중간점 (단순히 직선의 중간점들을 생성)
    final int steps = 10; // 중간점 개수
    for (int i = 1; i < steps; i++) {
      final double ratio = i / steps;
      final double lat = startLat + (endLat - startLat) * ratio;
      final double lng = startLng + (endLng - startLng) * ratio;

      // 약간의 랜덤성 추가 (직선이 아닌 곡선처럼 보이게)
      final double latJitter = (math.Random().nextDouble() - 0.5) * 0.001;
      final double lngJitter = (math.Random().nextDouble() - 0.5) * 0.001;

      route.add({'latitude': lat + latJitter, 'longitude': lng + lngJitter});
    }

    // 종료점
    route.add({'latitude': endLat, 'longitude': endLng});

    return route;
  }

  // 경로 그리기 메서드
  Future<void> _drawRouteToRestaurant(String restaurantId) async {
    // 현재 위치 확인
    Position? position = await _getCurrentLocation();
    if (position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('현재 위치를 가져올 수 없습니다')));
      return;
    }

    // 선택한 가게 정보 확인
    final restaurant = _restaurantData[restaurantId];
    if (restaurant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('가게 정보를 찾을 수 없습니다')));
      return;
    }

    try {
      // 프로그레스 표시
      setState(() {
        _isAddingLabels = true; // 기존 로딩 인디케이터 재활용
      });

      // MapProvider 접근
      final mapProvider = Provider.of<MapProvider>(context, listen: false);

      // 출발지와 목적지 설정
      mapProvider.setOrigin(
        position.latitude,
        position.longitude,
        name: '현재 위치',
      );

      mapProvider.setDestination(
        restaurant.latitude,
        restaurant.longitude,
        name: restaurant.name,
      );

      // 경로 요청
      await mapProvider.fetchRoute(
        priority: 'RECOMMEND',
        alternatives: false,
        roadDetails: true,
      );

      setState(() {
        _isAddingLabels = false;
        _showRoutePanel = true; // 길찾기 패널 표시 상태 설정 추가
      });

      // 길찾기 결과를 모달로 표시
      if (mapProvider.routeResponse != null &&
          mapProvider.routeResponse!.routes.isNotEmpty) {
        // 기존 showModalBottomSheet 대신 OverlayEntry 사용
        // 이미 존재하는 오버레이 제거 (전역 변수로 _overlayEntry 추가 필요)
        _overlayEntry?.remove();

        // 새 오버레이 생성
        _overlayEntry = OverlayEntry(
          builder:
              (context) => Positioned(
                left: 0,
                right: 0,
                bottom: 30, // 하단 컨트롤 패널 위에 위치
                child: Material(
                  color: Colors.transparent,
                  child: RouteSummaryModal(
                    route: mapProvider.routeResponse!.routes[0],
                  ),
                ),
              ),
        );

        // 오버레이 삽입
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        // 오류 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로 요청 오류: ${mapProvider.routeError}')),
        );
      }
    } catch (e) {
      setState(() {
        _isAddingLabels = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('경로 그리기 오류: $e')));
    }
  }

  // 경로 검색 메서드
  Future<void> _searchRoute() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    setState(() {
      _isAddingLabels = true; // 로딩 표시
    });

    try {
      // 경로 요청
      await mapProvider.fetchRoute(
        priority: 'RECOMMEND',
        alternatives: false,
        roadDetails: true,
      );

      // 모달 표시는 fetchRoute 내부에서 처리되도록 하거나,
      // 여기서 처리할 수도 있습니다.
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('경로 검색 실패: $e')));
    } finally {
      setState(() {
        _isAddingLabels = false;
      });
    }
  }

  // 테스트용 라벨 클릭 시뮬레이션 (실제 구현에서는 Native에서 호출됨)
  void _simulateLabelClick(String labelId) {
    _handleLabelClick(labelId);
  }

  // 출발지와 도착지가 모두 설정되었는지 확인하고 자동으로 경로 검색
  void _checkAndSearchRoute() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // 출발지와 도착지가 모두 설정되었는지 확인
    if (mapProvider.originLabel != null &&
        mapProvider.destinationLabel != null) {
      // 이전과 다른 출발지/도착지인 경우에만 검색 실행
      final originId = mapProvider.originLabel!.id;
      final destId = mapProvider.destinationLabel!.id;

      if (originId != _lastOriginId || destId != _lastDestinationId) {
        _lastOriginId = originId;
        _lastDestinationId = destId;

        // 경로 검색 실행
        Future.microtask(() {
          _searchRoute();
        });
      }
    }
  }

@override
Widget build(BuildContext context) {
  final mapProvider = Provider.of<MapProvider>(context);
  final statusBarHeight = MediaQuery.of(context).viewPadding.top;
  
  // 출발지나 도착지가 설정되었는지 확인하고 자동으로 경로 검색
  if (mapProvider.originLabel != null && mapProvider.destinationLabel != null) {
    Future.microtask(() {
      _checkAndSearchRoute();
    });
  }
  
  return Scaffold(
    // 전체 상태바 설정
    extendBodyBehindAppBar: true,
    appBar: _showRoutePanel
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.light,
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
              _moveToCurrentLocation();
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

        // 상단 패널 - 상태 표시줄부터 시작하여 자연스럽게 연결
        if (_showRoutePanel)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.white,
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상태 표시줄 영역
                  SizedBox(height: statusBarHeight),
                  
                  // 경로 검색 패널 - 내부 마진 제거
                  RouteSearchPanel(
                    originName: mapProvider.originLabel?.text,
                    destinationName: mapProvider.destinationLabel?.text,
                    onOriginTap: () {
                      // 출발지 선택 화면으로 이동
                    },
                    onDestinationTap: () {
                      // 도착지 선택 화면으로 이동
                    },
                    onSwapLocations: () {
                      // 출발지와 도착지 교체 로직
                      if (mapProvider.originLabel != null &&
                          mapProvider.destinationLabel != null) {
                        final originLabel = mapProvider.originLabel!;
                        final destLabel = mapProvider.destinationLabel!;

                        mapProvider.setOrigin(
                          destLabel.latitude,
                          destLabel.longitude,
                          name: destLabel.text,
                        );

                        mapProvider.setDestination(
                          originLabel.latitude,
                          originLabel.longitude,
                          name: originLabel.text,
                        );
                        
                        Future.microtask(() {
                          if (mapProvider.originLabel != null && 
                              mapProvider.destinationLabel != null) {
                            _searchRoute();
                          }
                        });
                      }
                    },
                    onReset: () {
                      // 출발지, 도착지 초기화 로직
                      mapProvider.resetRouteState();
                    },
                    onClose: () {
                      setState(() {
                        _showRoutePanel = false;
                      });
                      // 경로 및 관련 데이터 초기화
                      mapProvider.resetRouteState();
                    },
                    onSearch: null,
                  ),
                ],
              ),
            ),
          ),

        // 뒤로가기 버튼 (패널이 표시되지 않을 때만 표시)
        if (!_showRoutePanel)
          Positioned(
            top: statusBarHeight,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkGray),
              onPressed: () => Navigator.pop(context),
            ),
          ),

        // 현재 위치 버튼
        Positioned(
          right: 16,
          bottom: 400,
          child: FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _moveToCurrentLocation,
            backgroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
        
        // 길찾기 버튼
        Positioned(
          right: 16,
          bottom: 450,
          child: FloatingActionButton(
            heroTag: 'directions',
            onPressed: () {
              print("길찾기 버튼 클릭!");
              Future.microtask(() {
                setState(() {
                  _showRoutePanel = !_showRoutePanel;
                });
              });
              print("_showRoutePanel: $_showRoutePanel");
            },
            backgroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.directions, color: AppColors.primary),
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
                                    Duration(milliseconds: 500),
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

                  // 위치 트래킹 컨트롤
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          _isLocationTracking
                              ? Icons.location_off
                              : Icons.location_on,
                        ),
                        label: Text(
                          _isLocationTracking ? '위치 추적 중지' : '위치 추적 시작',
                        ),
                        onPressed:
                            _mapInitialized
                                ? () {
                                  if (_isLocationTracking) {
                                    _stopLocationTracking();
                                  } else {
                                    _startLocationTracking();
                                    _moveToCurrentLocation();
                                  }
                                  setState(() {}); // UI 업데이트
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLocationTracking ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
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
  final _LabelExampleScreenState screenState;

  const RestaurantBottomSheet({
    Key? key,
    required this.restaurantInfo,
    required this.screenState,
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
                  // 길찾기 기능 호출
                  Navigator.pop(context); // 바텀 시트 닫기
                  screenState._drawRouteToRestaurant(restaurantInfo.id);
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
