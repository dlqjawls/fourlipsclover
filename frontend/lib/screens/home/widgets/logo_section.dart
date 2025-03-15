import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          // 여기에는 실제 로고 이미지를 사용하세요
          Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
          const SizedBox(width: 8),
          Text(
            '네잎클로버',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}