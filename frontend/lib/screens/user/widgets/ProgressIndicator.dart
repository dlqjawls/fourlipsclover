import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class CloverScoreIndicator extends StatelessWidget {
  final int cloverCount;

  const CloverScoreIndicator({Key? key, required this.cloverCount})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.eco, // 클로버 아이콘
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '행운 점수',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (cloverCount % 100) / 100, // 100점 단위로 프로그레스 표시
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$cloverCount 클로버',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '다음 레벨까지 ${100 - (cloverCount % 100)}점',
                  style: TextStyle(color: AppColors.lightGray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
