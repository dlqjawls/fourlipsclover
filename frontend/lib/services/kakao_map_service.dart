// lib/services/kakao_map_platform_interface.dart
import 'package:flutter/services.dart';

class KakaoMapPlatform {
  static const MethodChannel _channel = MethodChannel('com.patriot.fourlipsclover/kakao_map');
  
  // 맵 초기화
static Future<bool> initializeMap() async {
    try {
      print('채널 호출: initializeMap');
      final bool result = await _channel.invokeMethod('initializeMap');
      print('채널 응답: $result');
      return result;
    } on PlatformException catch (e) {
      print('메서드 채널 오류: ${e.message}');
      return false;
    }
  }
  
  // 맵 중심 위치 설정
  static Future<void> setMapCenter({
    required double latitude, 
    required double longitude,
    int zoomLevel = 3,
  }) async {
    try {
      await _channel.invokeMethod('setMapCenter', {
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
      });
    } on PlatformException catch (e) {
      print('맵 중심 설정 오류: ${e.message}');
    }
  }
  
  // 마커 추가
  static Future<void> addMarker({
    required double latitude, 
    required double longitude,
    String? title,
  }) async {
    try {
      await _channel.invokeMethod('addMarker', {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
      });
    } on PlatformException catch (e) {
      print('마커 추가 오류: ${e.message}');
    }
  }
}