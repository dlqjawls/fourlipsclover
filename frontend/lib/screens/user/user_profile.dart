import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/config/routes.dart';

class MyConsumptionPatternScreen extends StatelessWidget {
  const MyConsumptionPatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('나의 프로필'),
        centerTitle: true,
        backgroundColor: AppColors.verylightGray,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('나의 소비 패턴 분석(beta)'),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 32),
            _buildBadgeSection(),
            const SizedBox(height: 32),
            _buildKeywordSection(),
            const SizedBox(height: 32),
            _buildAttendanceSection(),
            const SizedBox(height: 32),
            _buildMostVisitedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGray,
      ),
    );
  }

  Widget _buildChart() {
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

  Widget _buildBadgeSection() {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text(
            '대표 뱃지',
            style: TextStyle(
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '현지 마스터',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('나의 맛집 키워드'),
        const SizedBox(height: 16),
        Container(
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
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _KeywordChip(label: '육식'),
              _KeywordChip(label: '매콤한맛'),
              _KeywordChip(label: '양식'),
              _KeywordChip(label: '달달한 맛'),
              _KeywordChip(label: '어머니의 손맛'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('나의 출석 일수는 ?'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_florist, color: AppColors.primary, size: 40),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(text: '총 '),
                    TextSpan(
                      text: '400',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    const TextSpan(text: ' 일'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMostVisitedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('가장 많이 방문한 맛집은?'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: Text(
            '우리집',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;

  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: AppColors.darkGray)),
      avatar: Icon(Icons.local_florist, color: AppColors.primary, size: 18),
      backgroundColor: AppColors.background,
      side: BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
