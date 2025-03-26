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
      
      // 맵 초기화
      final result = await KakaoMapPlatform.initializeMap();
      print('카카오맵 초기화 결과: $result');
      
      // 맵 상태 설정
      if (result) {
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
        
        // 로딩 상태 업데이트
        _mapProvider!.setLoadingState(MapLoadingState.success);
        
        // 맵 생성 콜백 호출
        if (widget.onMapCreated != null) {
          widget.onMapCreated!();
        }
      } else {
        _mapProvider!.setLoadingState(
          MapLoadingState.failure,
          '지도 초기화 실패',
        );
      }
    } catch (e) {
      print('카카오맵 초기화 오류: $e');
      _mapProvider!.setLoadingState(
        MapLoadingState.failure,
        e.toString(),
      );
    }
  }
  
  // Provider 리스닝 설정
  void _setupProviderListeners() {
    if (!widget.listenToProvider || _mapProvider == null) return;
    
    // Provider 값이 변경될 때마다 네이티브 메서드 호출
    _mapProvider!.addListener(() async {
      try {
        // 중심 위치 변경 감지
        await KakaoMapPlatform.setMapCenter(
          latitude: _mapProvider!.centerLatitude,
          longitude: _mapProvider!.centerLongitude,
          zoomLevel: _mapProvider!.zoomLevel,
        );
        
        // 추가 리스너 설정 (마커, 지도 타입 등)
        // 여기에 추가 기능 구현
      } catch (e) {
        print('지도 업데이트 오류: $e');
      }
    });
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