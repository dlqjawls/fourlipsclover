// TODO Implement this library.
// lib/screens/group_plan/group_widgets/analysis/charts/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class CommonWidgets {
  // 인사이트 카드
  static Widget buildInsightCard({
    required String title,
    required List<String> insights,
  }) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: AppColors.primary.withOpacity(0.3),
      color: AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primaryLight.withOpacity(0.4),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkest,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...insights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.darkGray,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // 범례 항목
  static Widget buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: AppColors.darkGray, fontSize: 14)),
      ],
    );
  }

  // 테이블 셀 위젯
  static Widget buildTableCell(
    String text, {
    bool isHeader = false,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color:
              textColor ?? (isHeader ? AppColors.primary : AppColors.darkGray),
          fontWeight:
              fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal),
          fontSize: isHeader ? 14 : 12,
        ),
      ),
    );
  }
}
