// lib/providers/map_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/kakao_route_service.dart';
import '../services/kakao_map_service.dart';
import '../models/route_model.dart';
import '../utils/map_utils.dart';

class MapMarker {
  final double latitude;
  final double longitude;
  final String? title;
  final String? id;
  final bool isSelected;

  MapMarker({
    required this.latitude,
    required this.longitude,
    this.title,
    this.id,
    this.isSelected = false,
  });

  MapMarker copyWith({
    double? latitude,
    double? longitude,
    String? title,
    String? id,
    bool? isSelected,
  }) {
    return MapMarker(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      id: id ?? this.id,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// 카카오맵 라벨(마커) 클래스 - 색상 속성 제거
class MapLabel {
  final String id;
  final double latitude;
  final double longitude;
  final String? text;
  final String? imageAsset; // 라벨에 사용할 이미지 에셋 경로
  final double? textSize;
  final double? alpha; // 투명도 (0.0~1.0)
  final double? rotation; // 회전 각도 (도 단위)
  final int zIndex; // 라벨 표시 순서 (값이 클수록 위에 표시)
  final bool isClickable; // 클릭 가능 여부
  final bool isVisible; // 표시 여부
  final bool isSelected; // 선택 상태

  MapLabel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.text,
    this.imageAsset,
    this.textSize,
    this.alpha = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    this.isClickable = true,
    this.isVisible = true,
    this.isSelected = false,
  });

  MapLabel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? text,
    String? imageAsset,
    double? textSize,
    double? alpha,
    double? rotation,
    int? zIndex,
    bool? isClickable,
    bool? isVisible,
    bool? isSelected,
  }) {
    return MapLabel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      text: text ?? this.text,
      imageAsset: imageAsset ?? this.imageAsset,
      textSize: textSize ?? this.textSize,
      alpha: alpha ?? this.alpha,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isClickable: isClickable ?? this.isClickable,
      isVisible: isVisible ?? this.isVisible,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

enum MapLoadingState { loading, success, failure }

class MapProvider extends ChangeNotifier {
  // 중심 위치
  double _centerLatitude = 35.1958;
  double _centerLongitude = 126.8149;

  // 줌 레벨
  int _zoomLevel = 15;

  // 마커 컬렉션
  List<MapMarker> _markers = [];

  // 라벨 컬렉션 추가
  List<MapLabel> _labels = [];

  // 선택된 마커 ID
  String? _selectedMarkerId;

  // 선택된 라벨 ID 추가
  String? _selectedLabelId;

  // 지도 로딩 상태
  MapLoadingState _loadingState = MapLoadingState.loading;

  // 마지막 에러 메시지
  String? _lastError;

  // 지도 UI 커스텀 옵션
  bool _showLabels = true;
  bool _showCurrentLocation = false;

  // 바운딩 박스 (현재 보이는 영역)
  double? _northLatitude;
  double? _southLatitude;
  double? _eastLongitude;
  double? _westLongitude;

  // 경로 관련 속성
  KakaoRouteResponse? _routeResponse;
  bool _isRouteFetching = false;
  String? _routeError;
  List<String> _routeLineIds = [];
  // 출발지/목적지 위치 속성 추가
  MapLabel? _originLabel;
  MapLabel? _destinationLabel;
  List<MapLabel> _waypointLabels = [];

  // Getters
  double get centerLatitude => _centerLatitude;
  double get centerLongitude => _centerLongitude;
  int get zoomLevel => _zoomLevel;
  List<MapMarker> get markers => List.unmodifiable(_markers);
  List<MapLabel> get labels => List.unmodifiable(_labels);
  String? get selectedMarkerId => _selectedMarkerId;
  String? get selectedLabelId => _selectedLabelId;
  MapLoadingState get loadingState => _loadingState;
  String? get lastError => _lastError;
  bool get showLabels => _showLabels;
  bool get showCurrentLocation => _showCurrentLocation;
  //길찾기 게터
  KakaoRouteResponse? get routeResponse => _routeResponse;
  bool get isRouteFetching => _isRouteFetching;
  String? get routeError => _routeError;
  bool get hasRoute => _routeResponse != null;
  List<String> get routeLineIds => List.unmodifiable(_routeLineIds);
  // 출발지/목적지 getter
  MapLabel? get originLabel => _originLabel;
  MapLabel? get destinationLabel => _destinationLabel;
  List<MapLabel> get waypointLabels => List.unmodifiable(_waypointLabels);

  // 바운딩 박스 getter
  Map<String, double?> get viewportBounds => {
    'north': _northLatitude,
    'south': _southLatitude,
    'east': _eastLongitude,
    'west': _westLongitude,
  };

  // 선택된 마커 getter
  MapMarker? get selectedMarker {
    if (_selectedMarkerId == null) return null;
    try {
      return _markers.firstWhere((marker) => marker.id == _selectedMarkerId);
    } catch (e) {
      return null;
    }
  }

  // 선택된 라벨 getter
  MapLabel? get selectedLabel {
    if (_selectedLabelId == null) return null;
    try {
      return _labels.firstWhere((label) => label.id == _selectedLabelId);
    } catch (e) {
      return null;
    }
  }

  // 중심 위치 변경
  void setMapCenter({
    required double latitude,
    required double longitude,
    int? zoomLevel,
  }) {
    _centerLatitude = latitude;
    _centerLongitude = longitude;
    if (zoomLevel != null) {
      _zoomLevel = zoomLevel;
    }
    notifyListeners();
  }

  // 줌 레벨 변경
  void setZoomLevel(int zoomLevel) {
    _zoomLevel = zoomLevel;
    notifyListeners();
  }

  // 마커 추가
  void addMarker({
    required double latitude,
    required double longitude,
    String? title,
    String? id,
    bool select = false,
  }) {
    final markerId = MapUtils.generateLabelId("marker", id);

    final newMarker = MapMarker(
      latitude: latitude,
      longitude: longitude,
      title: title,
      id: markerId,
      isSelected: select,
    );

    _markers.add(newMarker);

    if (select) {
      _selectedMarkerId = markerId;
    }

    notifyListeners();
  }

  // 라벨 추가 메서드 - 최종 수정
void addLabel({
  required double latitude, // y 값 (경도)
  required double longitude, // x 값 (위도)
  String? text,
  String? imageAsset,
  double? textSize,
  double alpha = 1.0,
  double rotation = 0.0,
  int zIndex = 0,
  bool isClickable = true,
  bool isVisible = true,
  bool select = false,
  String? id,
}) {
  // 좌표 유효성 검사 - 수정된 버전
  if (!MapUtils.isValidKoreaCoordinate(latitude, longitude)) {
    // 유효성 검사 실패 시 로그 추가
    print('유효하지 않은 좌표: lat=$latitude, lng=$longitude');
    // 검사 실패해도 계속 진행
    // return; // 이 부분 제거 또는 주석 처리
  }

  final labelId = MapUtils.generateLabelId("label", id);

  final newLabel = MapLabel(
    id: labelId,
    latitude: latitude,
    longitude: longitude,
    text: text,
    imageAsset: imageAsset,
    textSize: textSize,
    alpha: alpha,
    rotation: rotation,
    zIndex: zIndex,
    isClickable: isClickable,
    isVisible: isVisible,
    isSelected: select,
  );

  _labels.add(newLabel);

  if (select) {
    _selectedLabelId = labelId;
  }

  notifyListeners();
}

  // 마커 일괄 설정
  void setMarkers(List<MapMarker> markers) {
    _markers = List.from(markers);
    notifyListeners();
  }

  // 라벨 일괄 설정
  void setLabels(List<MapLabel> labels) {
    _labels = List.from(labels);
    notifyListeners();
  }

  // 마커 제거
  void removeMarker(String id) {
    _markers.removeWhere((marker) => marker.id == id);

    if (_selectedMarkerId == id) {
      _selectedMarkerId = null;
    }

    notifyListeners();
  }

  // 라벨 제거
  void removeLabel(String id) {
    _labels.removeWhere((label) => label.id == id);

    if (_selectedLabelId == id) {
      _selectedLabelId = null;
    }

    notifyListeners();
  }

  // 모든 마커 제거
  void clearMarkers() {
    _markers.clear();
    _selectedMarkerId = null;
    notifyListeners();
  }

  // 모든 라벨 제거
  void clearLabels() {
    _labels.clear();
    _selectedLabelId = null;
    notifyListeners();
  }

  // 마커 선택
  void selectMarker(String id) {
    _selectedMarkerId = id;

    // 마커 상태 업데이트
    final updatedMarkers = _markers.map((marker) {
      return marker.copyWith(isSelected: marker.id == id);
    }).toList();

    _markers = updatedMarkers;
    notifyListeners();
  }

  // 라벨 선택
  void selectLabel(String id) {
    _selectedLabelId = id;

    // 라벨 상태 업데이트
    final updatedLabels = _labels.map((label) {
      return label.copyWith(isSelected: label.id == id);
    }).toList();

    _labels = updatedLabels;
    notifyListeners();
  }

  // 마커 선택 취소
  void deselectMarker() {
    _selectedMarkerId = null;

    // 마커 상태 업데이트
    final updatedMarkers = _markers.map((marker) {
      return marker.copyWith(isSelected: false);
    }).toList();

    _markers = updatedMarkers;
    notifyListeners();
  }

  // 라벨 선택 취소
  void deselectLabel() {
    _selectedLabelId = null;

    // 라벨 상태 업데이트
    final updatedLabels = _labels.map((label) {
      return label.copyWith(isSelected: false);
    }).toList();

    _labels = updatedLabels;
    notifyListeners();
  }

  // 라벨 업데이트
  void updateLabel(MapLabel updatedLabel) {
    final index = _labels.indexWhere((label) => label.id == updatedLabel.id);
    if (index != -1) {
      _labels[index] = updatedLabel;
      notifyListeners();
    }
  }

  // 라벨 위치 업데이트
  void updateLabelPosition(String id, double latitude, double longitude) {
    final index = _labels.indexWhere((label) => label.id == id);
    if (index != -1) {
      _labels[index] = _labels[index].copyWith(
        latitude: latitude,
        longitude: longitude,
      );
      notifyListeners();
    }
  }

  // 라벨 텍스트 업데이트
  void updateLabelText(String id, String text) {
    final index = _labels.indexWhere((label) => label.id == id);
    if (index != -1) {
      _labels[index] = _labels[index].copyWith(text: text);
      notifyListeners();
    }
  }

  // 라벨 가시성 토글
  void toggleLabelVisibility(String id, bool isVisible) {
    final index = _labels.indexWhere((label) => label.id == id);
    if (index != -1) {
      _labels[index] = _labels[index].copyWith(isVisible: isVisible);
      notifyListeners();
    }
  }

  // 지도 로딩 상태 설정
  void setLoadingState(MapLoadingState state, [String? error]) {
    _loadingState = state;
    _lastError = error;
    notifyListeners();
  }

  // 라벨 표시 전환
  void toggleLabels(bool show) {
    _showLabels = show;
    notifyListeners();
  }

  // 현재 위치 표시 전환
  void toggleCurrentLocation(bool show) {
    _showCurrentLocation = show;
    notifyListeners();
  }

  // 현재 보이는 영역 설정
  void setViewportBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) {
    _northLatitude = north;
    _southLatitude = south;
    _eastLongitude = east;
    _westLongitude = west;
    notifyListeners();
  }

  // 출발지 설정 메서드
  void setOrigin(double latitude, double longitude, {String? name}) {
    // 기존 출발지 라벨 제거
    if (_originLabel != null) {
      removeLabel(_originLabel!.id);
    }

    // 새 출발지 라벨 추가
    final labelId = MapUtils.generateLabelId("origin", null);

    _originLabel = MapLabel(
      id: labelId,
      latitude: latitude,
      longitude: longitude,
      text: name ?? '출발',
      imageAsset: 'swallow',
      textSize: 16,
      zIndex: 10,
      isClickable: true,
    );

    // 라벨 목록에 추가
    _labels.add(_originLabel!);
    notifyListeners();
  }

  // 목적지 설정 메서드
  void setDestination(double latitude, double longitude, {String? name}) {
    // 기존 목적지 라벨 제거
    if (_destinationLabel != null) {
      removeLabel(_destinationLabel!.id);
    }

    // 새 목적지 라벨 추가
    final labelId = MapUtils.generateLabelId("destination", null);

    _destinationLabel = MapLabel(
      id: labelId,
      latitude: latitude,
      longitude: longitude,
      text: name ?? '도착',
      imageAsset: 'clover',
      textSize: 16,
      zIndex: 10,
      isClickable: true,
    );

    // 라벨 목록에 추가
    _labels.add(_destinationLabel!);
    notifyListeners();
  }

  // 경유지 추가 메서드
  void addWaypoint(double latitude, double longitude, {String? name}) {
    final labelId = MapUtils.generateLabelId("waypoint", null);

    final waypoint = MapLabel(
      id: labelId,
      latitude: latitude,
      longitude: longitude,
      text: name ?? '경유지',
      imageAsset: 'swallow',
      textSize: 16,
      zIndex: 5,
      isClickable: true,
    );

    // 경유지 목록에 추가
    _waypointLabels.add(waypoint);

    // 라벨 목록에도 추가
    _labels.add(waypoint);
    notifyListeners();
  }

  // 경유지 제거 메서드
  void removeWaypoint(String id) {
    _waypointLabels.removeWhere((waypoint) => waypoint.id == id);
    removeLabel(id);
    notifyListeners();
  }

  // 모든 경유지 제거
  void clearWaypoints() {
    for (var waypoint in _waypointLabels) {
      removeLabel(waypoint.id);
    }
    _waypointLabels.clear();
    notifyListeners();
  }

  // 경로 탐색 메서드
  Future<void> fetchRoute({
    String priority = 'RECOMMEND',
    bool alternatives = false,
    bool roadDetails = true,
    String carFuel = 'GASOLINE',
    bool carHipass = false,
  }) async {
    // 출발지나 목적지가 설정되지 않은 경우
    if (_originLabel == null || _destinationLabel == null) {
      _routeError = '출발지와 목적지를 모두 설정해주세요';
      notifyListeners();
      return;
    }

    try {
      _isRouteFetching = true;
      _routeError = null;
      notifyListeners();

      // 경유지 좌표 리스트 생성
      List<Map<String, double>>? waypoints;
      if (_waypointLabels.isNotEmpty) {
        waypoints = _waypointLabels.map((label) => {
            'longitude': label.longitude,
            'latitude': label.latitude,
          }).toList();
      }

      // 기존 경로 제거
      clearRoutes();

      // 카카오 모빌리티 API 호출
      final response = await KakaoRouteService.getCarRoute(
        originLng: _originLabel!.longitude,
        originLat: _originLabel!.latitude,
        destinationLng: _destinationLabel!.longitude,
        destinationLat: _destinationLabel!.latitude,
        waypoints: waypoints,
        priority: priority,
        alternatives: alternatives,
        roadDetails: roadDetails,
        carFuel: carFuel,
        carHipass: carHipass,
      );

      _routeResponse = response;
      _isRouteFetching = false;
      notifyListeners();

      // 성공적으로 경로를 받으면 지도에 표시
      if (response.routes.isNotEmpty && response.routes[0].resultCode == 0) {
        await drawRouteOnMap(response.routes[0]);
      }
    } catch (e) {
      _isRouteFetching = false;
      _routeError = '경로 검색 실패: $e';
      notifyListeners();
    }
  }

  // 경로를 지도에 그리는 메서드
  Future<void> drawRouteOnMap(KakaoRoute route) async {
    try {
      int sectionIndex = 0;

      // 각 구간별로 경로 그리기
      for (final section in route.sections) {
        if (section.roads == null || section.roads!.isEmpty) continue;

        // 구간별로 모든 도로 세그먼트의 좌표를 하나의 리스트로 합침
        List<Map<String, double>> allCoordinates = [];

        for (final road in section.roads!) {
          final coordinates = road.getCoordinatesForDrawRoute();
          if (coordinates.isNotEmpty) {
            allCoordinates.addAll(coordinates);
          }
        }

        if (allCoordinates.isNotEmpty) {
          final routeId = MapUtils.generateLabelId("route", "${DateTime.now().millisecondsSinceEpoch}_$sectionIndex");

          // 섹션 별로 다른 색상 사용
          final colors = [
            0xFF4285F4,
            0xFFEA4335,
            0xFFFBBC05,
            0xFF34A853,
            0xFF9C27B0,
          ];
          final color = colors[sectionIndex % colors.length];

          // 경로 그리기 API 호출
          await KakaoMapPlatform.drawRoute(
            routeId: routeId,
            coordinates: allCoordinates,
            lineColor: color,
            lineWidth: 5.0,
            showArrow: true,
          );

          // 그려진 경로 ID 저장
          _routeLineIds.add(routeId);
        }

        sectionIndex++;
      }

      // 카메라를 경로가 모두 보이는 영역으로 이동
      final bound = route.summary.bound;
      if (bound != null) {
        final centerLat = (bound.minY + bound.maxY) / 2;
        final centerLng = (bound.minX + bound.maxX) / 2;
        
        // 줌 레벨 계산
        final latDiff = bound.maxY - bound.minY;
        final lngDiff = bound.maxX - bound.minX;
        final zoomLevel = MapUtils.calculateZoomLevel(latDiff, lngDiff);

        setMapCenter(
          latitude: centerLat,
          longitude: centerLng,
          zoomLevel: zoomLevel,
        );
      }

      notifyListeners();
    } catch (e) {
      _routeError = '경로 표시 실패: $e';
      notifyListeners();
    }
  }

  // 경로 제거 메서드
  Future<void> clearRoutes() async {
    try {
      // KakaoMapPlatform을 통해 모든 경로 제거
      await KakaoMapPlatform.clearRoutes();

      // 저장된 경로 ID 목록 초기화
      _routeLineIds.clear();
      _routeResponse = null;
      notifyListeners();
    } catch (e) {
      print('경로 제거 실패: $e');
    }
  }

  // 모든 길찾기 관련 상태 초기화
  void resetRouteState() {
    clearRoutes();
    
    // 출발지, 목적지, 경유지 라벨 제거
    if (_originLabel != null) {
      removeLabel(_originLabel!.id);
      _originLabel = null;
    }
    
    if (_destinationLabel != null) {
      removeLabel(_destinationLabel!.id);
      _destinationLabel = null;
    }
    
    clearWaypoints();
    
    _routeResponse = null;
    _routeError = null;
    _isRouteFetching = false;
    notifyListeners();
  }

  // 지도 상태 초기화
  void resetMapState() {
    _centerLatitude = 35.1958;
    _centerLongitude = 126.8149;
    _zoomLevel = 15;
    _markers = [];
    _labels = [];
    _selectedMarkerId = null;
    _selectedLabelId = null;
    _loadingState = MapLoadingState.loading;
    _lastError = null;
    _showLabels = true;
    _showCurrentLocation = false;
    _northLatitude = null;
    _southLatitude = null;
    _eastLongitude = null;
    _westLongitude = null;

    // 경로 관련 상태 초기화
    _routeResponse = null;
    _routeError = null;
    _isRouteFetching = false;
    _routeLineIds = [];
    _originLabel = null;
    _destinationLabel = null;
    _waypointLabels = [];
    notifyListeners();
  }
}