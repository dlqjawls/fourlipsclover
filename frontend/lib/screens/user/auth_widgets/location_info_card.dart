import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:geolocator/geolocator.dart';

class LocationInfoCard extends StatelessWidget {
  final Position position;

  const LocationInfoCard({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // SizedBox 추가
      width: double.infinity, // 부모 너비에 맞춤
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.verylightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildLocationInfo('위도', position.latitude),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.lightGray),
            ),
            _buildLocationInfo('경도', position.longitude),
          ],
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
