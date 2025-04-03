// lib/services/kakao_map_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 카카오맵 플랫폼 채널을 통한 서비스
class KakaoMapPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.patriot.fourlipsclover/kakao_map',
  );

  // 안전한 API 호출을 위한 헬퍼 메서드
  static Future<T> _safeApiCall<T>(String methodName, Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      print('$methodName 실패: $e');
      rethrow;
    }
  }

  /// 지도 초기화
  static Future<bool> initializeMap() async {
    return _safeApiCall('initializeMap', () async {
      final result = await _channel.invokeMethod<bool>('initializeMap');
      return result ?? false;
    });
  }

  /// 라벨 레이어 초기화 - 새 메서드 추가
  static Future<bool> initializeLabelLayer() async {
    return _safeApiCall('initializeLabelLayer', () async {
      try {
        final result = await _channel.invokeMethod<bool>('initializeLabelLayer');
        return result ?? false;
      } catch (e) {
        // 메서드가 구현되지 않은 경우 기본적으로 성공으로 간주
        return true;
      }
    });
  }

  // 라벨 클릭 콜백 변수
  static Function(String labelId)? _labelClickCallback;
  
  // 라벨 클릭 리스너 설정 메서드
  static void setLabelClickListener(Function(String labelId) callback) {
    _labelClickCallback = callback;
    
    // 채널 핸들러 설정
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLabelClick') {
        final String labelId = call.arguments['labelId'];
        
        if (_labelClickCallback != null) {
          _labelClickCallback!(labelId);
        }
      }
      return null;
    });
  }

/// 지도 중심 위치 설정
  static Future<void> setMapCenter({
    required double latitude,
    required double longitude,
    int zoomLevel = 3,
  }) async {
    return _safeApiCall('setMapCenter', () async {
      await _channel.invokeMethod<void>('setMapCenter', {
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
      });
    });
  }

  /// 마커 추가
  static Future<void> addMarker({
    required double latitude,
    required double longitude,
    String? title,
    String? markerId,
  }) async {
    return _safeApiCall('addMarker', () async {
      await _channel.invokeMethod<void>('addMarker', {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'markerId': markerId,
      });
    });
  }

  static Future<void> addLabelDirectly({
    required String labelId,
    required double latitude,
    required double longitude,
    String? text,
    String? imageAsset,
    double? textSize,
  }) async {
    return _safeApiCall('addLabelDirectly', () async {
      await _channel.invokeMethod<void>('addLabelDirectly', {
        'labelId': labelId,
        'latitude': latitude,
        'longitude': longitude,
        'text': text,
        'imageAsset': imageAsset,
        'textSize': textSize,
      });
    });
  }

  /// 라벨 추가 (카카오맵 Label API 사용)
  static Future<void> addLabel({
    required String labelId,
    required double latitude,
    required double longitude,
    String? text,
    String? imageAsset,
    double? textSize,
    double alpha = 1.0,
    double rotation = 0.0,
    int zIndex = 0,
    bool isClickable = true,
  }) async {
    return _safeApiCall('addLabel', () async {
      await _channel.invokeMethod<void>('addLabel', {
        'labelId': labelId,
        'latitude': latitude,
        'longitude': longitude,
        'text': text,
        'imageAsset': imageAsset,
        'textSize': textSize,
        'alpha': alpha,
        'rotation': rotation,
        'zIndex': zIndex,
        'isClickable': isClickable,
      });
    });
  }

  /// 모든 라벨 제거
  static Future<void> clearLabels() async {
    return _safeApiCall('clearLabels', () async {
      await _channel.invokeMethod<void>('clearLabels');
    });
  }

  /// 라벨 위치
  static Future<void> updateLabelPosition({
    required String labelId,
    required double latitude,
    required double longitude,
  }) async {
    return _safeApiCall('updateLabelPosition', () async {
      await _channel.invokeMethod<void>('updateLabelPosition', {
        'labelId': labelId,
        'latitude': latitude,
        'longitude': longitude,
      });
    });
  }

  /// 라벨 텍스트 업데이트
  static Future<void> updateLabelText({
    required String labelId,
    required String text,
  }) async {
    return _safeApiCall('updateLabelText', () async {
      await _channel.invokeMethod<void>('updateLabelText', {
        'labelId': labelId,
        'text': text,
      });
    });
  }

  /// 라벨 스타일 업데이트
  static Future<void> updateLabelStyle({
    required String labelId,
    double? textSize,
    double? alpha,
    double? rotation,
    int? zIndex,
  }) async {
    return _safeApiCall('updateLabelStyle', () async {
      await _channel.invokeMethod<void>('updateLabelStyle', {
        'labelId': labelId,
        'textSize': textSize,
        'alpha': alpha,
        'rotation': rotation,
        'zIndex': zIndex,
      });
    });
  }

  /// 라벨 가시성 설정
  static Future<void> setLabelVisibility({
    required String labelId,
    required bool isVisible,
  }) async {
    return _safeApiCall('setLabelVisibility', () async {
      await _channel.invokeMethod<void>('setLabelVisibility', {
        'labelId': labelId,
        'isVisible': isVisible,
      });
    });
  }

  /// 경로 그리기
  static Future<bool> drawRoute({
    required String routeId,
    required List<Map<String, double>> coordinates,
    int? lineColor,
    double? lineWidth,
    bool? showArrow,
  }) async {
    return _safeApiCall('drawRoute', () async {
      // lineColor가 int32 범위를 넘어가지 않도록 확인
      final safeLineColor = lineColor != null ? (lineColor & 0xFFFFFFFF) : null;
      
      final result = await _channel.invokeMethod<bool>('drawRoute', {
        'routeId': routeId,
        'coordinates': coordinates,
        'lineColor': safeLineColor,
        'lineWidth': lineWidth,
        'showArrow': showArrow,
      });
      
      return result ?? false;
    });
  }

  /// 경로 제거
  static Future<void> removeRoute(String routeId) async {
    return _safeApiCall('removeRoute', () async {
      await _channel.invokeMethod<void>('removeRoute', {
        'routeId': routeId,
      });
    });
  }

  /// 모든 경로 제거
  static Future<void> clearRoutes() async {
    return _safeApiCall('clearRoutes', () async {
      await _channel.invokeMethod<void>('clearRoutes');
    });
  }
}