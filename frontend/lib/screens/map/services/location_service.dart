// lib/screens/map/services/location_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/kakao/kakao_map_service.dart';
import '../../../providers/map_provider.dart';

/// 위치 서비스 클래스 - 위치 관련 기능 캡슐화
class LocationService {
  final BuildContext context;
  final MapProvider mapProvider;
  final String userLocationLabelId;
  
  // 위치 추적 관련 변수
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLocationTracking = false;
  Position? _currentPosition;
  
  LocationService({
    required this.context, 
    required this.mapProvider,
    this.userLocationLabelId = 'user_location_marker',
  });
  
  bool get isLocationTracking => _isLocationTracking;
  Position? get currentPosition => _currentPosition;

  // 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.')),
      );
      return null;
    }

    // 권한 체크
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 권한이 거부되었습니다.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.')),
      );
      return null;
    }

    // 현재 위치 가져오기
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      print('위치 가져오기 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 위치를 가져오는데 실패했습니다.')),
      );
      return null;
    }
  }

  // 현재 위치 마커 추가
  Future<void> addUserLocationMarker(double latitude, double longitude) async {
    try {
      bool markerExists = mapProvider.labels.any(
        (label) => label.id == userLocationLabelId,
      );

      // Provider에서만 제거 (이미 있는 경우)
      if (markerExists) {
        mapProvider.removeLabel(userLocationLabelId);
      }

      // 사용자 위치 마커 추가
      await KakaoMapPlatform.addLabel(
        labelId: userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
        text: null, // 텍스트 없음
        imageAsset: 'swallow', // 현재 위치 마커 이미지
        textSize: null,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 10, // 다른 마커보다 위에 표시되도록 높은 zIndex 설정
        isClickable: false, // 클릭 불가능하게 설정
      );

      // Provider에도 추가
      mapProvider.addLabel(
        id: userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
        text: null,
        imageAsset: 'swallow',
        textSize: null,
        alpha: 1.0,
        rotation: 0.0,
        zIndex: 10,
        isClickable: false,
      );

      print('사용자 위치 마커 추가됨: ($latitude, $longitude)');
    } catch (e) {
      print('사용자 위치 마커 추가 오류: $e');
    }
  }

  // 위치 추적 시작
  void startLocationTracking() {
    if (_isLocationTracking) return;

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터마다 업데이트
      ),
    ).listen((Position position) {
      // 위치가 업데이트될 때마다 호출됨
      updateUserLocationMarker(position.latitude, position.longitude);
      _currentPosition = position;
    });

    _isLocationTracking = true;
    print('위치 추적 시작됨');
  }

  // 위치 추적 중지
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isLocationTracking = false;
    print('위치 추적 중지됨');
  }

  // 사용자 위치 마커 업데이트
  Future<void> updateUserLocationMarker(
    double latitude,
    double longitude,
  ) async {
    try {
      // 위치 마커 업데이트
      await KakaoMapPlatform.updateLabelPosition(
        labelId: userLocationLabelId,
        latitude: latitude,
        longitude: longitude,
      );

      // Provider 업데이트
      mapProvider.updateLabelPosition(
        userLocationLabelId,
        latitude,
        longitude,
      );

      print('사용자 위치 마커 업데이트됨: ($latitude, $longitude)');
    } catch (e) {
      print('사용자 위치 마커 업데이트 오류: $e');
    }
  }

  // 현재 위치로 이동
  Future<void> moveToCurrentLocation() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      // 사용자 위치로 지도 이동
      await KakaoMapPlatform.setMapCenter(
        latitude: position.latitude,
        longitude: position.longitude,
        zoomLevel: 16, // 적절한 줌 레벨
      );

      // 사용자 위치 마커 표시
      await addUserLocationMarker(position.latitude, position.longitude);

      // 위치 추적 시작 (아직 시작되지 않았다면)
      if (!_isLocationTracking) {
        startLocationTracking();
      }
    }
  }
  
  // 서비스 정리
  void dispose() {
    stopLocationTracking();
  }
}