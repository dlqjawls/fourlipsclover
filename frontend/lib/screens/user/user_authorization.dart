import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/auth_widgets/location_check_button.dart';
import 'package:frontend/screens/user/auth_widgets/location_status_card.dart';

class UserAuthorizationScreen extends StatefulWidget {
  const UserAuthorizationScreen({super.key});

  @override
  State<UserAuthorizationScreen> createState() =>
      _UserAuthorizationScreenState();
}

class _UserAuthorizationScreenState extends State<UserAuthorizationScreen> {
  Position? _currentPosition;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print('위치 권한 승인됨');
    } else {
      setState(() {
        _message = '위치 권한이 필요합니다';
      });
      print('위치 권한 거부됨');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;

    final status = await Permission.location.status;

    // 권한이 영구적으로 거부된 경우
    if (status.isPermanentlyDenied) {
      // 설정으로 이동하는 다이얼로그 표시
      if (mounted) {
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

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      }
      return;
    }

    // 권한이 없는 경우 권한 재요청
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        setState(() {
          _message = '위치 권한이 필요합니다';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _message = '위치를 확인하는 중...';
    });

    try {
      print('위치 정보 요청 시작');
      // 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _message = '기기의 위치 서비스를 켜주세요';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _message = '현재 위치 확인 완료!';
        print('위치 확인 성공: ${position.latitude}, ${position.longitude}');
      });
    } catch (e) {
      print('위치 확인 오류: $e');
      setState(() {
        _message = '위치 확인에 실패했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        title: const Text(
          '현지인 인증',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.verylightGray,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGray),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _currentPosition != null),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: LocationStatusCard(
                currentPosition: _currentPosition,
                message: _message,
                isLoading: _isLoading,
                onPressed: _getCurrentLocation,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
