import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/config/theme.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontSize: 12);
                  final titles = ['양식', '일식', '한식', '디저트', '분식'];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(titles[value.toInt()], style: style),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 9)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5)]),
          ],
        ),
      ),
    );
  }
}
