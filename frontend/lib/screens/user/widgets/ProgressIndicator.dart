import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ProgressIndicatorSection extends StatelessWidget {
  const ProgressIndicatorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.spa, color: AppColors.primaryDark),
        const SizedBox(width: 8),
        const Text('행운게이지:', style: TextStyle(color: AppColors.mediumGray)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: AppColors.mediumGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryDark,
              ),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('80%', style: TextStyle(color: AppColors.mediumGray)),
      ],
    );
  }
}
