// lib/widgets/kakao_map_native_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/kakao_map_service.dart';

class KakaoMapNativeView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final Function? onMapCreated;
  
  const KakaoMapNativeView({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.zoomLevel = 3,
    this.onMapCreated,
  }) : super(key: key);

  @override
  State<KakaoMapNativeView> createState() => _KakaoMapNativeViewState();
}

class _KakaoMapNativeViewState extends State<KakaoMapNativeView> {
  @override
  void initState() {
    super.initState();
    print('카카오맵 뷰 초기화 시작');
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    try {
      final result = await KakaoMapPlatform.initializeMap();
      print('카카오맵 초기화 결과: $result');
      await KakaoMapPlatform.initializeMap();
      await KakaoMapPlatform.setMapCenter(
        latitude: widget.latitude,
        longitude: widget.longitude,
        zoomLevel: widget.zoomLevel,
      );
      await KakaoMapPlatform.addMarker(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      
      if (widget.onMapCreated != null) {
        widget.onMapCreated!();
      }
    } catch (e) {
      print('카카오맵 초기화 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 안드로이드용 네이티브 뷰
    const String viewType = 'com.patriot.fourlipsclover/kakao_map_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'zoomLevel': widget.zoomLevel,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}