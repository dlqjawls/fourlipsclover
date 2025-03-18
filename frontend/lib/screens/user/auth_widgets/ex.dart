import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/config/theme.dart';

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
      _getCurrentLocation();
    } else {
      setState(() {
        _message = '위치 권한이 필요합니다';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    print('위치 확인 시작');
    setState(() {
      _isLoading = true;
      _message = '위치를 확인하는 중...';
    });

    try {
      print('Geolocator로 위치 정보 요청 중...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('위치 정보 수신 성공:');
      print('위도: ${position.latitude}');
      print('경도: ${position.longitude}');

      setState(() {
        _currentPosition = position;
        _message = '현재 위치 확인 완료!';
        _isLoading = false;
      });

      // 상태 변경이 화면에 반영될 시간을 줌
      // await Future.delayed(const Duration(seconds: 2));

      // // 성공 후 이전 화면으로 돌아가기
      // if (mounted) {
      //   Navigator.pop(context, true);
      // }
    } catch (e) {
      print('위치 확인 오류 발생: $e');
      setState(() {
        _message = '위치 확인 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray, // 배경색 통일
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
      body: SingleChildScrollView(
        // ScrollView 추가
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.background, // 카드 배경색을 하얀색으로
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '현지인 인증을 위해\n현재 위치를 확인합니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.mediumGray,
                        height: 1.4,
                      ),
                    ),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.verylightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildLocationInfo(
                              '위도',
                              _currentPosition!.latitude,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.lightGray),
                            ),
                            _buildLocationInfo(
                              '경도',
                              _currentPosition!.longitude,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.lightGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            '위치 확인하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value.toStringAsFixed(6),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
