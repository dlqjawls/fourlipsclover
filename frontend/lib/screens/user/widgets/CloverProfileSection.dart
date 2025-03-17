import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/config/theme.dart';

class CloverProfileSection extends StatelessWidget {
  const CloverProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '나의 클로버',
          style: TextStyle(color: AppColors.darkGray, fontSize: 25, fontWeight: FontWeight.bold ),
        
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thumb_up, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '현지 마스터',
              style: TextStyle(color: AppColors.darkGray, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGray,
          ),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png', // SVG 파일 경로
              width: 600,
              height: 600,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '누군가',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '현지인 인증 완료!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
