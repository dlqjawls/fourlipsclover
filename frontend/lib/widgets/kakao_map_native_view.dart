// lib/widgets/kakao_map_native_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../services/kakao_map_service.dart';

class KakaoMapNativeView extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? zoomLevel;
  final Function? onMapCreated;
  final bool listenToProvider;

  const KakaoMapNativeView({
    Key? key,
    this.latitude,
    this.longitude,
    this.zoomLevel,
    this.onMapCreated,
    this.listenToProvider = true,
  }) : super(key: key);

  @override
  State<KakaoMapNativeView> createState() => _KakaoMapNativeViewState();
}

class _KakaoMapNativeViewState extends State<KakaoMapNativeView> {
  MapProvider? _mapProvider;

  double? _prevCenterLat;
  double? _prevCenterLng;
  int? _prevZoomLevel;
  List<String>? _prevLabelIds;

  @override
  void initState() {
    super.initState();
    print('카카오맵 뷰 초기화 시작');
    // Provider 초기화는 didChangeDependencies에서 처리
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mapProvider = Provider.of<MapProvider>(context);

    // 처음 Provider에 연결될 때만 초기화
    if (_mapProvider == null) {
      _mapProvider = mapProvider;
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
  try {
    // Provider에서 값 가져오기 (위젯 속성으로 오버라이드 가능)
    final latitude = widget.latitude ?? _mapProvider!.centerLatitude;
    final longitude = widget.longitude ?? _mapProvider!.centerLongitude;
    final zoomLevel = widget.zoomLevel ?? _mapProvider!.zoomLevel;

    // 좌표 유효성 검사 추가
    if (!_isValidCoordinate(latitude, longitude)) {
      print('잘못된 좌표: latitude=$latitude, longitude=$longitude');
      _mapProvider!.setLoadingState(MapLoadingState.failure, '유효하지 않은 좌표');
      return;
    }

    // 맵 초기화
    final result = await KakaoMapPlatform.initializeMap();
    print('카카오맵 초기화 결과: $result');

    // 맵 상태 설정
    if (result) {
      // 라벨 레이어 명시적 초기화 시도 (이 부분 추가)
      final labelLayerInitResult = await KakaoMapPlatform.initializeLabelLayer();
      print('라벨 레이어 초기화 결과: $labelLayerInitResult');

      // 중심 위치 설정
      await KakaoMapPlatform.setMapCenter(
        latitude: latitude,
        longitude: longitude,
        zoomLevel: zoomLevel,
      );

      // Provider 업데이트 (위젯에서 값을 전달받은 경우)
      if (widget.latitude != null && widget.longitude != null) {
        _mapProvider!.setMapCenter(
          latitude: latitude,
          longitude: longitude,
          zoomLevel: zoomLevel,
        );
      }

      // 마커 설정
      for (var marker in _mapProvider!.markers) {
        await KakaoMapPlatform.addMarker(
          latitude: marker.latitude,
          longitude: marker.longitude,
          title: marker.title,
        );
      }

      // 라벨 설정 추가
      await _updateLabels();

      // 로딩 상태 업데이트
      _mapProvider!.setLoadingState(MapLoadingState.success);

      // 맵 생성 콜백 호출
      if (widget.onMapCreated != null) {
        widget.onMapCreated!();
      }
    } else {
      _mapProvider!.setLoadingState(MapLoadingState.failure, '지도 초기화 실패');
    }
  } catch (e) {
    print('카카오맵 초기화 오류: $e');
    _mapProvider!.setLoadingState(MapLoadingState.failure, e.toString());
  }
}

// 좌표 유효성 검사 메서드 추가
bool _isValidCoordinate(double latitude, double longitude) {
  // 한국 지역 대략적인 좌표 범위
  const minLat = 33.0;
  const maxLat = 43.0;
  const minLng = 125.0;
  const maxLng = 131.0;

  return (latitude >= minLat && latitude <= maxLat) &&
         (longitude >= minLng && longitude <= maxLng);
}

  // 리스너 설정 메서드
  void _setupProviderListeners() {
    if (!widget.listenToProvider || _mapProvider == null) return;
    
    // 초기값 설정
    _prevCenterLat = _mapProvider!.centerLatitude;
    _prevCenterLng = _mapProvider!.centerLongitude;
    _prevZoomLevel = _mapProvider!.zoomLevel;
    _prevLabelIds = _mapProvider!.labels.map((label) => label.id).toList();
    
    _mapProvider!.addListener(() {
      try {
        // 중요한 변경 사항만 체크
        if (_prevCenterLat != _mapProvider!.centerLatitude ||
            _prevCenterLng != _mapProvider!.centerLongitude ||
            _prevZoomLevel != _mapProvider!.zoomLevel) {
          
          _prevCenterLat = _mapProvider!.centerLatitude;
          _prevCenterLng = _mapProvider!.centerLongitude;
          _prevZoomLevel = _mapProvider!.zoomLevel;
          
          // 중심점 변경
          KakaoMapPlatform.setMapCenter(
            latitude: _mapProvider!.centerLatitude,
            longitude: _mapProvider!.centerLongitude,
            zoomLevel: _mapProvider!.zoomLevel,
          );
        }
        
        // 라벨 변경 감지 - 간단하게 ID 목록 비교
        final currentLabelIds = _mapProvider!.labels.map((label) => label.id).toList();
        if (_labelsChanged(currentLabelIds)) {
          _prevLabelIds = currentLabelIds;
          _updateLabels();
        }
      } catch (e) {
        print('지도 업데이트 오류: $e');
      }
    });
  }
  
  // 라벨 변경 감지
  bool _labelsChanged(List<String> currentLabelIds) {
    if (_prevLabelIds == null) return true;
    if (_prevLabelIds!.length != currentLabelIds.length) return true;
    
    // 간단한 비교를 위해 정렬 후 비교
    final prevSorted = List<String>.from(_prevLabelIds!)..sort();
    final currentSorted = List<String>.from(currentLabelIds)..sort();
    
    for (int i = 0; i < prevSorted.length; i++) {
      if (prevSorted[i] != currentSorted[i]) return true;
    }
    
    return false;
  }
  
  // 라벨 업데이트 처리
Future<void> _updateLabels() async {
  print("라벨 업데이트 시작: 총 ${_mapProvider!.labels.length}개");
  
  // 중복 호출 방지를 위해 Set 사용
  final uniqueLabels = _mapProvider!.labels.toSet();
  
  await KakaoMapPlatform.clearLabels();
  
  for (var label in uniqueLabels) {
    try {
      await KakaoMapPlatform.addLabel(
        labelId: label.id,
        latitude: label.longitude,
        longitude: label.latitude,
        text: label.text,
        imageAsset: label.imageAsset,
        textSize: label.textSize,
        alpha: label.alpha ?? 1.0,
        rotation: label.rotation ?? 0.0,
        zIndex: label.zIndex,
        isClickable: label.isClickable,
      );
      print("라벨 추가 성공: ${label.id} (${label.text})");
    } catch (e) {
      print("라벨 추가 실패: ${label.id}, 오류: $e");
    }
  }
  
  print("모든 라벨 업데이트 완료");
}

  @override
  Widget build(BuildContext context) {
    // Provider에서 최신 값 가져오기
    final mapProvider = Provider.of<MapProvider>(context);
    final latitude = widget.latitude ?? mapProvider.centerLatitude;
    final longitude = widget.longitude ?? mapProvider.centerLongitude;
    final zoomLevel = widget.zoomLevel ?? mapProvider.zoomLevel;

    // Provider가 변경됐다면 리스너 재설정
    if (_mapProvider != mapProvider) {
      _mapProvider = mapProvider;
      _setupProviderListeners();
    }

    // 안드로이드용 네이티브 뷰
    const String viewType = 'com.patriot.fourlipsclover/kakao_map_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'zoomLevel': zoomLevel,
      'showLabels': mapProvider.showLabels,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        // 지도 뷰가 생성된 후 리스너 설정
        _setupProviderListeners();
      },
    );
  }

  @override
  void dispose() {
    // Provider 리스너 클린업 (필요하다면)
    super.dispose();
  }
}
