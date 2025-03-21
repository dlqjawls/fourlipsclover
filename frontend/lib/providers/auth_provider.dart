import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/services/local_certification_service.dart';
import 'package:frontend/models/local_certification_model.dart';

class AuthProvider extends ChangeNotifier {
  Position? _currentPosition;
  String _locationMessage = '';
  bool _isLoading = false;
  bool _isAuthorized = false;
  String _regionName = '';
  String get regionName => _regionName;
  final LocalCertificationService _localCertificationService =
      LocalCertificationService();
  LocalCertification? _localCertification;

  // Getters
  Position? get currentPosition => _currentPosition;
  String get locationMessage => _locationMessage;
  bool get isLoading => _isLoading;
  bool get isAuthorized => _isAuthorized;
  LocalCertification? get localCertification => _localCertification;

  // 상태 업데이트 메서드
  void updateState({
    Position? position,
    String? message,
    bool? loading,
    bool? authorized,
    LocalCertification? certification,
  }) {
    if (position != null) _currentPosition = position;
    if (message != null) _locationMessage = message;
    if (loading != null) _isLoading = loading;
    if (authorized != null) _isAuthorized = authorized;
    if (certification != null) {
      _localCertification = certification;
      _regionName = certification.localRegion.regionName; // 지역 이름 저장
    }
    notifyListeners();
  }

  // 현재 위치 가져오기
  Future<void> getCurrentLocation(BuildContext context) async {
    updateState(loading: true);

    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        updateState(message: '위치 서비스를 활성화해주세요.', loading: false);
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          updateState(message: '위치 권한이 거부되었습니다.', loading: false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        updateState(
          message: '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',
          loading: false,
        );
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      updateState(
        position: position,
        message: '현재 위치를 가져왔습니다.',
        loading: false,
      );
    } catch (e) {
      updateState(message: '위치를 가져오는데 실패했습니다: $e', loading: false);
    }
  }

  // 현지인 인증 생성
  Future<void> createLocalCertification(int memberId) async {
    if (_currentPosition == null) {
      updateState(message: '위치 정보가 필요합니다.');
      return;
    }

    try {
      updateState(loading: true);

      final certification = await _localCertificationService
          .createLocalCertification(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
          );

      _localCertification = certification;
      updateState(
        authorized: true,
        message: '현지인 인증이 완료되었습니다.',
        loading: false,
      );
    } catch (e) {
      updateState(message: '현지인 인증에 실패했습니다: $e', loading: false);
    }
  }

  // 초기화
  void reset() {
    _currentPosition = null;
    _locationMessage = '';
    _isLoading = false;
    _isAuthorized = false;
    _localCertification = null;
    notifyListeners();
  }
}
