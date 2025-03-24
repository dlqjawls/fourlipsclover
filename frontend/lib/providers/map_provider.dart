// lib/providers/map_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

enum MapType {
  normal,
  satellite,
  hybrid,
  terrain,
}

enum MapLoadingState {
  loading,
  success,
  failure,
}

class MapProvider extends ChangeNotifier {
  // 중심 위치
  double _centerLatitude = 35.1958;
  double _centerLongitude = 126.8149;
  
  // 줌 레벨
  int _zoomLevel = 3;
  
  // 지도 타입
  MapType _mapType = MapType.normal;
  
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
  bool _showBuildings = true;
  bool _showTraffic = false;
  bool _showCurrentLocation = false;
  bool _nightMode = false;
  
  // 바운딩 박스 (현재 보이는 영역)
  double? _northLatitude;
  double? _southLatitude;
  double? _eastLongitude;
  double? _westLongitude;

  // Getters
  double get centerLatitude => _centerLatitude;
  double get centerLongitude => _centerLongitude;
  int get zoomLevel => _zoomLevel;
  MapType get mapType => _mapType;
  List<MapMarker> get markers => List.unmodifiable(_markers);
  List<MapLabel> get labels => List.unmodifiable(_labels); // 라벨 getter 추가
  String? get selectedMarkerId => _selectedMarkerId;
  String? get selectedLabelId => _selectedLabelId; // 선택된 라벨 ID getter 추가
  MapLoadingState get loadingState => _loadingState;
  String? get lastError => _lastError;
  bool get showLabels => _showLabels;
  bool get showBuildings => _showBuildings;
  bool get showTraffic => _showTraffic;
  bool get showCurrentLocation => _showCurrentLocation;
  bool get nightMode => _nightMode;
  
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
  
  // 선택된 라벨 getter 추가
  MapLabel? get selectedLabel {
    if (_selectedLabelId == null) return null;
    try {
      return _labels.firstWhere((label) => label.id == _selectedLabelId);
    } catch (e) {
      return null;
    }
  }

  // 중심 위치 변경
  void setMapCenter({required double latitude, required double longitude, int? zoomLevel}) {
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

  // 지도 타입 변경
  void setMapType(MapType mapType) {
    _mapType = mapType;
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
    final markerId = id ?? '${latitude}_${longitude}_${DateTime.now().millisecondsSinceEpoch}';
    
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
  
  // 라벨 추가 메서드 - 색상 매개변수 제거
  void addLabel({
    required double latitude,
    required double longitude,
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
    final labelId = id ?? 'label_${latitude}_${longitude}_${DateTime.now().millisecondsSinceEpoch}';
    
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
      return marker.copyWith(
        isSelected: marker.id == id,
      );
    }).toList();
    
    _markers = updatedMarkers;
    notifyListeners();
  }
  
  // 라벨 선택
  void selectLabel(String id) {
    _selectedLabelId = id;
    
    // 라벨 상태 업데이트
    final updatedLabels = _labels.map((label) {
      return label.copyWith(
        isSelected: label.id == id,
      );
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

  // 건물 표시 전환
  void toggleBuildings(bool show) {
    _showBuildings = show;
    notifyListeners();
  }

  // 교통정보 표시 전환
  void toggleTraffic(bool show) {
    _showTraffic = show;
    notifyListeners();
  }

  // 현재 위치 표시 전환
  void toggleCurrentLocation(bool show) {
    _showCurrentLocation = show;
    notifyListeners();
  }

  // 야간 모드 전환
  void toggleNightMode(bool enable) {
    _nightMode = enable;
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

  // 지도 상태 초기화
  void resetMapState() {
    _centerLatitude = 35.1958;
    _centerLongitude = 126.8149;
    _zoomLevel = 3;
    _mapType = MapType.normal;
    _markers = [];
    _labels = []; // 라벨 초기화 추가
    _selectedMarkerId = null;
    _selectedLabelId = null; // 선택된 라벨 ID 초기화 추가
    _loadingState = MapLoadingState.loading;
    _lastError = null;
    _showLabels = true;
    _showBuildings = true;
    _showTraffic = false;
    _showCurrentLocation = false;
    _nightMode = false;
    _northLatitude = null;
    _southLatitude = null;
    _eastLongitude = null;
    _westLongitude = null;
    notifyListeners();
  }
}