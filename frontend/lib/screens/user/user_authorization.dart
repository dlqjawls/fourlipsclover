import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/config/theme.dart';
import 'auth_widgets/location_status_card.dart';
import 'auth_widgets/location_check_button.dart';

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

    setState(() {
      _isLoading = true;
      _message = '위치를 확인하는 중...';
    });

    try {
      print('위치 정보 요청 시작');
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
          child: Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: LocationStatusCard(
                      currentPosition: _currentPosition,
                      message: _message,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: LocationCheckButton(
                  isLoading: _isLoading,
                  onPressed: _getCurrentLocation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
