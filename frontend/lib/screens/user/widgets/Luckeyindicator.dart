import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class LuckGaugeIndicator extends StatelessWidget {
  final int luckGauge;

  const LuckGaugeIndicator({Key? key, required this.luckGauge}) : super(key: key);

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
                Icon(Icons.stars, color: AppColors.primary),
                SizedBox(width: 8),
                Text('행운 게이지', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,  
                )),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (luckGauge % 100) / 100,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text('현재 행운 게이지: $luckGauge',
              style: TextStyle(color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }
}