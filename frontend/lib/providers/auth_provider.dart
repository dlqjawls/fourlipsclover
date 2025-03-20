import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthProvider with ChangeNotifier {
  // 현재 위치 정보를 저장하는 변수
  Position? _currentPosition;
  // 위치 정보 요청 중인지 여부를 나타내는 변수
  bool _isLoading = false;
  // 위치 정보 관련 메시지를 저장하는 변수
  String _locationMessage = '';
  // 위치 인증이 완료되었는지 여부를 나타내는 변수
  bool _isAuthorized = false;

  // 각 변수에 대한 getter 메서드들
  bool get isAuthorized => _isAuthorized;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String get locationMessage => _locationMessage;

  // 앱 시작시 인증 상태를 로드하는 초기화 메서드
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthorized = prefs.getBool('isAuthorized') ?? false;
    notifyListeners();
  }

  // 현재 위치 정보를 가져오는 메서드
  Future<void> getCurrentLocation(BuildContext context) async {
    if (_isLoading) return; // 이미 요청 중이면 중복 요청 방지

    final status = await Permission.location.status;

    // 위치 권한이 영구적으로 거부된 경우 처리
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('위치 권한 필요'),
                content: const Text('위치 권한이 필요합니다.\n설정에서 권한을 허용해주세요.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('설정으로 이동'),
                  ),
                ],
              ),
        );

        // 설정으로 이동하기로 한 경우
        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      }
      return;
    }

    // 위치 권한이 없는 경우 권한 요청
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        updateState(message: '위치 권한이 필요합니다');
        return;
      }
    }

    // 위치 정보 요청 시작
    updateState(isLoading: true, message: '위치를 확인하는 중...');

    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        updateState(message: '기기의 위치 서비스를 켜주세요');
        return;
      }

      // 실제 위치 정보 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 위치 정보 저장 및 상태 업데이트
      _currentPosition = position;
      _isAuthorized = true;
      updateState(message: '현재 위치 확인 완료!');
      print('위치 확인 성공: ${position.latitude}, ${position.longitude}');

      // 인증 상태 저장
      await saveAuthState();
    } catch (e) {
      print('위치 확인 오류: $e');
      updateState(message: '위치 확인에 실패했습니다.');
    } finally {
      updateState(isLoading: false);
    }
  }

  // 상태 업데이트를 위한 헬퍼 메서드
  void updateState({bool? isLoading, String? message}) {
    if (isLoading != null) _isLoading = isLoading;
    if (message != null) _locationMessage = message;
    notifyListeners();
  }

  // 인증 상태를 SharedPreferences에 저장하는 메서드
  Future<void> saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthorized', _isAuthorized);
  }

  // 모든 상태를 초기화하는 메서드
  void reset() {
    _currentPosition = null;
    _isAuthorized = false;
    _locationMessage = '';
    notifyListeners();
  }
}
