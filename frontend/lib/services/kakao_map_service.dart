// lib/services/kakao_map_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 카카오맵 플랫폼 채널을 통한 서비스
class KakaoMapPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.patriot.fourlipsclover/kakao_map',
  );

  /// 지도 초기화
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
    String? markerId,
  }) async {
    try {
      await _channel.invokeMethod<void>('addMarker', {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'markerId': markerId,
      });
    } catch (e) {
      print('마커 추가 실패: $e');
      rethrow;
    }
  }

  static Future<void> addLabelDirectly({
  required String labelId,
  required double latitude,
  required double longitude,
  String? text,
  String? imageAsset,
  double? textSize,
}) async {
  try {
    await _channel.invokeMethod<void>('addLabelDirectly', {
      'labelId': labelId,
      'latitude': latitude,
      'longitude': longitude,
      'text': text,
      'imageAsset': imageAsset,
      'textSize': textSize,
    });
  } catch (e) {
    print('라벨 직접 추가 실패: $e');
    rethrow;
  }
}

  /// 라벨 추가 (카카오맵 Label API 사용)
static Future<void> addLabel({
  required String labelId,
  required double latitude,
  required double longitude,
  String? text,
  String? imageAsset,
  // Color? textColor,         // 주석 처리
  double? textSize,
  // Color? backgroundColor,   // 주석 처리
  double alpha = 1.0,
  double rotation = 0.0,
  int zIndex = 0,
  bool isClickable = true,
}) async {
  try {
    print('addLabel 메서드 호출 전');
    print('파라미터: labelId=$labelId, 다른 파라미터들');

    await _channel.invokeMethod<void>('addLabel', {
      'labelId': labelId,
      'latitude': latitude,
      'longitude': longitude,
      'text': text,
      'imageAsset': imageAsset,
      // 'textColor': textColorInt,          // 주석 처리
      'textSize': textSize,
      // 'backgroundColor': backgroundColorInt,  // 주석 처리
      'alpha': alpha,
      'rotation': rotation,
      'zIndex': zIndex,
      'isClickable': isClickable,
    });

    print('addLabel 메서드 호출 ');
  } on PlatformException catch (e) {
    print('PlatformException 발생');
    print('코드: ${e.code}');
    print('메시지: ${e.message}');
    print('세부사항: ${e.details}');
    rethrow;
  } catch (e) {
    print('라벨 추가 실패: $e');
    rethrow;
  }
}
  /// 모든 라벨 제거
  static Future<void> clearLabels() async {
    try {
      await _channel.invokeMethod<void>('clearLabels');
    } catch (e) {
      print('모든 라벨 제거 실패: $e');
      rethrow;
    }
  }

  /// 라벨 위치
  static Future<void> updateLabelPosition({
    required String labelId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateLabelPosition', {
        'labelId': labelId,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('라벨 위치 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 라벨 텍스트 업데이트
  static Future<void> updateLabelText({
    required String labelId,
    required String text,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateLabelText', {
        'labelId': labelId,
        'text': text,
      });
    } catch (e) {
      print('라벨 텍스트 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 라벨 스타일 업데이트
static Future<void> updateLabelStyle({
  required String labelId,
  // Color? textColor,          // 주석 처리
  double? textSize,
  // Color? backgroundColor,    // 주석 처리
  double? alpha,
  double? rotation,
  int? zIndex,
}) async {
  try {
    // 색상을 ARGB 정수로 변환 (주석 처리)
    // int? textColorInt;
    // int? backgroundColorInt;
    // 
    // if (textColor != null) {
    //   textColorInt = textColor.value;
    // }
    // 
    // if (backgroundColor != null) {
    //   backgroundColorInt = backgroundColor.value;
    // }

    await _channel.invokeMethod<void>('updateLabelStyle', {
      'labelId': labelId,
      // 'textColor': textColorInt,            // 주석 처리
      'textSize': textSize,
      // 'backgroundColor': backgroundColorInt,  // 주석 처리
      'alpha': alpha,
      'rotation': rotation,
      'zIndex': zIndex,
    });
  } catch (e) {
    print('라벨 스타일 업데이트 실패: $e');
    rethrow;
  }
}

  /// 라벨 가시성 설정
  static Future<void> setLabelVisibility({
    required String labelId,
    required bool isVisible,
  }) async {
    try {
      await _channel.invokeMethod<void>('setLabelVisibility', {
        'labelId': labelId,
        'isVisible': isVisible,
      });
    } catch (e) {
      print('라벨 가시성 설정 실패: $e');
      rethrow;
    }
  }

  /// 지도 타입 설정
  static Future<void> setMapType(int mapType) async {
    try {
      await _channel.invokeMethod<void>('setMapType', {'mapType': mapType});
    } catch (e) {
      print('지도 타입 설정 실패: $e');
      rethrow;
    }
  }

  /// 지도 레이블 표시 설정
  static Future<void> setShowMapLabels(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowMapLabels', {'show': show});
    } catch (e) {
      print('지도 레이블 표시 설정 실패: $e');
      rethrow;
    }
  }

  /// 건물 표시 설정
  static Future<void> setShowBuildings(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowBuildings', {'show': show});
    } catch (e) {
      print('건물 표시 설정 실패: $e');
      rethrow;
    }
  }

  /// 교통정보 표시 설정
  static Future<void> setShowTraffic(bool show) async {
    try {
      await _channel.invokeMethod<void>('setShowTraffic', {'show': show});
    } catch (e) {
      print('교통정보 표시 설정 실패: $e');
      rethrow;
    }
  }

  /// 야간 모드 설정
  static Future<void> setNightMode(bool enable) async {
    try {
      await _channel.invokeMethod<void>('setNightMode', {'enable': enable});
    } catch (e) {
      print('야간 모드 설정 실패: $e');
      rethrow;
    }
  }
}
