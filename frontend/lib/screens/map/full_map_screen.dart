// lib/screens/map/full_map_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/services/api/search_api.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/map_provider.dart';
import '../../config/theme.dart';
import '../../services/kakao/kakao_map_service.dart';
import '../../widgets/kakao_map_native_view.dart';
import '../../widgets/custom_switch.dart';
import '../../models/restaurant_model.dart';

// 위젯 임포트
import 'widgets/restaurant_bottom_sheet.dart';
import 'widgets/route_panel.dart';
import 'widgets/map_controller.dart';
import 'widgets/route_summary_modal.dart';

// 서비스 임포트
import 'services/location_service.dart';
import 'services/label_service.dart';
import 'services/route_service.dart';

class FullMapScreen extends StatefulWidget {
  final String locationName;

  const FullMapScreen({Key? key, required this.locationName}) : super(key: key);

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  // 상태 변수
  bool _mapInitialized = false;
  bool _isLoading = false;
  bool _isAddingLabels = false;
  bool _showRoutePanel = false;
  String? _selectedLabelId;

  // 서비스 인스턴스
  late LocationService _locationService;
  late LabelService _labelService;
  late RouteService _routeService;

  // 데이터
  final Map<String, RestaurantResponse> _restaurantData = {};
  OverlayEntry? _overlayEntry;

  // lib/screens/map/full_map_screen.dart의 initState 부분을 수정

  @override
  void initState() {
    super.initState();

    // 지도 생성 후 초기화 작업 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 초기화 시 맵 센터 설정
      final mapProvider = Provider.of<MapProvider>(context, listen: false);

      // 기존 라벨이 있는 경우 그 중심으로 이동
      if (mapProvider.labels.isNotEmpty) {
        double sumLat = 0;
        double sumLng = 0;
        int validCount = 0;

        for (var label in mapProvider.labels) {
          sumLat += label.latitude;
          sumLng += label.longitude;
          validCount++;
        }

        if (validCount > 0) {
          mapProvider.setMapCenter(
            latitude: sumLat / validCount,
            longitude: sumLng / validCount,
            zoomLevel: 14, // 적절한 줌 레벨
          );
        }
      }

      // 이후 맵이 초기화되면 라벨 추가
      if (_mapInitialized) {
        _addLabelsToMap();
        // GPS 버튼을 누르지 않아도 현재 위치 표시 (선택적)
        // _locationService.moveToCurrentLocation();
      }

      // 지연 후 라벨 클릭 이벤트 리스너 설정 (네이티브 구성요소 초기화 시간 확보)
      Future.delayed(Duration(milliseconds: 1500), () {
        try {
          KakaoMapPlatform.setLabelClickListener((String labelId) {
            print('라벨 클릭됨 (Flutter): $labelId');
            if (mounted) {
              _handleLabelClick(labelId);
            }
          });
          print('라벨 클릭 리스너 설정 성공');
        } catch (e) {
          print('라벨 클릭 리스너 설정 실패: $e');
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 서비스 초기화 - Provider 참조를 포함하므로 didChangeDependencies에서 수행
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    _locationService = LocationService(
      context: context,
      mapProvider: mapProvider,
    );
    _labelService = LabelService(context: context, mapProvider: mapProvider);
    _routeService = RouteService(
      context: context,
      mapProvider: mapProvider,
      locationService: _locationService,
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _locationService.dispose();
    super.dispose();
  }

  // 라벨 클릭 처리 메서드
  Future<void> _handleLabelClick(String labelId) async {
    print('라벨 클릭 처리: $labelId');

    // 로딩 표시
    setState(() {
      _isLoading = true;
    });

    try {
      // API를 통해 레스토랑 상세 정보 가져오기
      final restaurant = await RestaurantSearchApi.getRestaurantDetails(
        labelId,
      );

      // 선택된 라벨 업데이트
      setState(() {
        _selectedLabelId = labelId;
        _isLoading = false;
      });

      // 선택된 라벨이 지도 중앙에 오도록 지도 이동
      if (restaurant.y != null && restaurant.x != null) {
        _labelService.centerMapOnRestaurant(restaurant);
      }

      // 바텀 시트 표시
      _showRestaurantBottomSheet(context, restaurant);
    } catch (e) {
      // 오류 처리
      print('레스토랑 정보 가져오기 실패: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('레스토랑 정보를 가져오는데 실패했습니다.')));
    }
  }

  // 바텀 시트 표시 메서드
  void _showRestaurantBottomSheet(
    BuildContext context,
    RestaurantResponse restaurant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 높이 조절 가능하게 설정
      backgroundColor: Colors.transparent, // 투명 배경
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        // 화면 높이의 1/3 정도의 크기로 설정
        return FractionallySizedBox(
          heightFactor: 0.31, // 화면 높이의 30%
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: RestaurantBottomSheet(
              restaurant: restaurant,
              onRouteButtonPressed: _drawRouteToRestaurant,
              currentPosition: _locationService.currentPosition,
            ),
          ),
        );
      },
    );
  }

  // 경로 그리기 메서드
  Future<void> _drawRouteToRestaurant(String restaurantId) async {
    if (_restaurantData.containsKey(restaurantId)) {
      await _routeService.drawRouteToRestaurant(
        restaurantId: restaurantId,
        restaurant: _restaurantData[restaurantId]!,
        setLoading: (value) => setState(() => _isLoading = value),
        setShowRoutePanel: (value) => setState(() => _showRoutePanel = value),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    // 경로 검색 체크
    if (_showRoutePanel &&
        mapProvider.originLabel != null &&
        mapProvider.destinationLabel != null) {
      Future.microtask(() {
        _routeService.checkAndSearchRoute(
          setLoading: (value) => setState(() => _isLoading = value),
        );
      });
    }

    return Scaffold(
      // 전체 상태바 설정
      extendBodyBehindAppBar: true,
      appBar:
          _showRoutePanel
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              )
              : AppBar(
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

                // 네이티브 지도에 라벨 추가
                _addLabelsToMap();
              },
            ),
          ),

          // 로딩 인디케이터
          if (mapProvider.loadingState == MapLoadingState.loading ||
              _isLoading ||
              _isAddingLabels)
            const Center(child: CircularProgressIndicator()),

          // 상단 패널 - 길찾기 모드일 때 표시
          if (_showRoutePanel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RoutePanel(
                originName: mapProvider.originLabel?.text,
                destinationName: mapProvider.destinationLabel?.text,
                onSwapLocations:
                    () => _routeService.swapLocations(
                      setLoading: (value) => setState(() => _isLoading = value),
                    ),
                onClose: () {
                  setState(() {
                    _showRoutePanel = false;
                  });
                  _routeService.resetRouteState();
                },
              ),
            ),

          // 지도 컨트롤러 (줌 및 현재 위치 버튼)
          MapController(
            onZoomIn: () => mapProvider.setZoomLevel(mapProvider.zoomLevel + 1),
            onZoomOut:
                () => mapProvider.setZoomLevel(mapProvider.zoomLevel - 1),
            onCurrentLocation: () => _locationService.moveToCurrentLocation(),
          ),

          // 경로 요약 정보 - 경로가 있을 때만 표시
          if (_showRoutePanel &&
              mapProvider.routeResponse != null &&
              mapProvider.routeResponse!.routes.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: RouteSummaryModal(
                route: mapProvider.routeResponse!.routes[0],
              ),
            ),
        ],
      ),
    );
  }

  // 네이티브 지도에 라벨 추가 후 처리 부분 수정
  Future<void> _addLabelsToMap() async {
    setState(() {
      _isAddingLabels = true;
    });

    final restaurants = await _labelService.addLabelsToMap(
      mapInitialized: _mapInitialized,
      setLoading: (value) => setState(() => _isAddingLabels = value),
    );

    setState(() {
      _restaurantData.clear();
      _restaurantData.addAll(restaurants);
      _isAddingLabels = false;
    });

    // 라벨이 추가되었는지 확인하고 지도 중심 설정
    if (_restaurantData.isNotEmpty) {
      // 바운딩 박스 계산
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      // 모든 라벨의 좌표를 포함하는 바운딩 박스 계산
      for (var restaurant in _restaurantData.values) {
        if (restaurant.y != null && restaurant.x != null) {
          if (restaurant.y! < minLat) minLat = restaurant.y!;
          if (restaurant.y! > maxLat) maxLat = restaurant.y!;
          if (restaurant.x! < minLng) minLng = restaurant.x!;
          if (restaurant.x! > maxLng) maxLng = restaurant.x!;
        }
      }

      // 유효한 바운딩 박스가 있으면 지도 중심 설정
      if (minLat != double.infinity) {
        final centerLat = (minLat + maxLat) / 2;
        final centerLng = (minLng + maxLng) / 2;

        // 데이터로부터 적절한 줌 레벨 계산 (간단한 예시)
        final latDiff = maxLat - minLat;
        final lngDiff = maxLng - minLng;
        int zoomLevel = 15; // 기본값

        // 영역 크기에 따라 줌 레벨 조정
        if (latDiff > 0.1 || lngDiff > 0.1)
          zoomLevel = 12;
        else if (latDiff > 0.05 || lngDiff > 0.05)
          zoomLevel = 13;
        else if (latDiff > 0.02 || lngDiff > 0.02)
          zoomLevel = 14;

        // 지도 중심 설정
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        mapProvider.setMapCenter(
          latitude: centerLat,
          longitude: centerLng,
          zoomLevel: zoomLevel,
        );

        print('지도 중심 자동 설정: lat=$centerLat, lng=$centerLng, zoom=$zoomLevel');
      } else {
        // 유효한 좌표가 없으면 기본 위치(한국 중심) 설정
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        mapProvider.setMapCenter(
          latitude: 36.5, // 한국 중심 위도
          longitude: 127.8, // 한국 중심 경도
          zoomLevel: 7, // 전국 보기에 적합한 줌 레벨
        );

        print('유효한 좌표 없음: 기본 위치로 설정');
      }
    }
  }
}
