// lib/services/kakao_map_service.dart
import 'package:flutter/services.dart';

/// 카카오맵 플랫폼 채널을 통한 서비스
class KakaoMapPlatform {
  static const MethodChannel _channel = MethodChannel('com.patriot.fourlipsclover/kakao_map');
  
  /// 지도 초기화
  static Future<bool> initializeMap() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('initializeMap');
      return result ?? false;
    } catch (e) {
      print('지도 초기화 메서드 호출 실패: $e');
      return false;
    }
  }
  
  /// 지도 중심 위치 설정
  static Future<void> setMapCenter({
    required double latitude,
    required double longitude,
    int zoomLevel = 3,
  }) async {
    try {
      await _channel.invokeMethod<void>('setMapCenter', {
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
      });
    } catch (e) {
      print('지도 중심 설정 실패: $e');
      rethrow;
    }
  }
  
  /// 마커 추가
  static Future<void> addMarker({
    required double latitude,
    required double longitude,
    String? title,
  }) async {
    try {
      await _channel.invokeMethod<void>('addMarker', {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
      });
    } catch (e) {
      print('마커 추가 실패: $e');
      rethrow;
    }
  }
  
  /// 마커 제거
  static Future<void> removeMarker(String markerId) async {
    try {
      await _channel.invokeMethod<void>('removeMarker', {
        'markerId': markerId,
      });
    } catch (e) {
      print('마커 제거 실패: $e');
      rethrow;
    }
  }
  
  /// 모든 마커 제거
  static Future<void> clearMarkers() async {
    try {
      await _channel.invokeMethod<void>('clearMarkers');
    } catch (e) {
      print('모든 마커 제거 실패: $e');
      rethrow;
    }
  }
  
  /// 지도 타입 설정
  static Future<void> setMapType(int mapType) async {
    try {
      await _channel.invokeMethod<void>('setMapType', {
        'mapType': mapType,
      });
    } catch (e) {
      print('지도 타입 설정 실패: $e');
      rethrow;
    }
  }
  
  /// 라벨 표시 설정
  static Future<void> setShowLabels(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowLabels', {
        'show': show,
      });
    } catch (e) {
      print('라벨 표시 설정 실패: $e');
      rethrow;
    }
  }
  
  /// 건물 표시 설정
  static Future<void> setShowBuildings(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowBuildings', {
        'show': show,
      });
    } catch (e) {
      print('건물 표시 설정 실패: $e');
      rethrow;
    }
  }
  
  /// 교통정보 표시 설정
  static Future<void> setShowTraffic(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowTraffic', {
        'show': show,
      });
    } catch (e) {
      print('교통정보 표시 설정 실패: $e');
      rethrow;
    }
  }
  
  /// 야간 모드 설정
  static Future<void> setNightMode(bool enable) async {
    try {
      await _channel.invokeMethod<void>('setNightMode', {
        'enable': enable,
      });
    } catch (e) {
      print('야간 모드 설정 실패: $e');
      rethrow;
    }
  }
}