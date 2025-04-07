import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class KeywordSection extends StatelessWidget {
  const KeywordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                '나의 맛집 키워드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: const [
              KeywordChip(label: '육식'),
              KeywordChip(label: '매콤한맛'),
              KeywordChip(label: '양식'),
              KeywordChip(label: '달달한 맛'),
              KeywordChip(label: '어머니의 손맛'),
            ],
          ),
        ],
      ),
    );
  }
}

class KeywordChip extends StatelessWidget {
  final String label;

  const KeywordChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
