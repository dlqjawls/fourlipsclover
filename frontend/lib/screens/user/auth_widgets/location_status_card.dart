import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'location_info_card.dart';

class LocationStatusCard extends StatelessWidget {
  final Position? currentPosition;
  final String message;

  const LocationStatusCard({
    super.key,
    this.currentPosition,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // SizedBox로 감싸서 너비 제어
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
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
          crossAxisAlignment: CrossAxisAlignment.stretch, // 자식 위젯들을 가로로 늘림
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.mediumGray,
                height: 1.4,
              ),
            ),
            if (currentPosition != null) ...[
              const SizedBox(height: 20),
              LocationInfoCard(position: currentPosition!),
            ],
          ],
        ),
      ),
    );
  }
}
