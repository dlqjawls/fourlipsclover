// TODO Implement this library.
// lib/screens/group_plan/group_widgets/analysis/charts/basic_comparison_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';

import 'common_widgets.dart';

class BasicComparisonTab extends StatelessWidget {
  final GroupAnalysisResult? analysisResult;

  const BasicComparisonTab({Key? key, required this.analysisResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 기본 비교 분석 데이터가 없는 경우
    if (analysisResult?.analyses['basic_comparison'] == null) {
      return const Center(child: Text('기본 비교 데이터가 없습니다'));
    }

    final basicComparison = analysisResult!.analyses['basic_comparison'] as BasicComparison;
    final data = basicComparison.data;

    // 데이터 처리 - 우리 그룹과 다른 그룹 분리
    var ourGroup = data.firstWhere(
      (item) => item.groupType == '우리 그룹',
      orElse: () => data.first, // 없으면 첫 항목 사용
    );
    
    var otherGroup = data.firstWhere(
      (item) => item.groupType == '다른 그룹', 
      orElse: () => data.first, // 없으면 첫 항목 사용
    );

    // 비교 비율 계산 (우리 그룹 / 다른 그룹)
    double avgSpendingRatio = otherGroup.avgSpending != 0 
        ? (ourGroup.avgSpending / otherGroup.avgSpending) 
        : 1.0;

    // 금액 포맷터
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인사이트 카드
          CommonWidgets.buildInsightCard(
            title: '소비 패턴 인사이트',
            insights: [
              '우리 그룹은 평균적으로 ${(avgSpendingRatio * 100 - 100).abs().toStringAsFixed(1)}% ${avgSpendingRatio > 1 ? '더 많이' : '적게'} 지출합니다.',
              '우리 그룹의 총 지출액은 ${formatCurrency.format(ourGroup.totalSpending)}입니다.',
              '총 ${ourGroup.transactionCount}회 결제가 이루어졌습니다.',
            ],
          ),

          const SizedBox(height: 24),

          // 평균 지출 비교 카드
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '평균 지출 비교',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 차트 영역
                  SizedBox(
                    height: 250,
                    child: _buildBasicComparisonChart(ourGroup, otherGroup),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 범례
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonWidgets.buildLegendItem('우리 그룹', AppColors.primary),
                      const SizedBox(width: 24),
                      CommonWidgets.buildLegendItem('다른 그룹', AppColors.lightGray),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 통계 요약 카드
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '통계 요약',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 그룹별 통계 비교
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          title: '우리 그룹',
                          avgSpending: formatCurrency.format(ourGroup.avgSpending),
                          totalSpending: formatCurrency.format(ourGroup.totalSpending),
                          transactionCount: ourGroup.transactionCount.toString(),
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 1,
                        color: AppColors.lightGray,
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          title: '다른 그룹',
                          avgSpending: formatCurrency.format(otherGroup.avgSpending),
                          totalSpending: formatCurrency.format(otherGroup.totalSpending),
                          transactionCount: otherGroup.transactionCount.toString(),
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기본 비교 차트
  Widget _buildBasicComparisonChart(
    BasicComparisonData ourGroup, 
    BasicComparisonData otherGroup
  ) {
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    // 데이터 그룹화
    final List<dynamic> chartData = [
      {'category': '평균 지출', 'our': ourGroup.avgSpending, 'other': otherGroup.avgSpending},
    ];

    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    double maxY = [ourGroup.avgSpending, otherGroup.avgSpending].reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(10),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String groupName = rodIndex == 0 ? '우리 그룹' : '다른 그룹';
              String amount = formatCurrency.format(rod.toY);
              return BarTooltipItem(
                '$groupName: $amount',
                const TextStyle(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                return const SizedBox.shrink(); // 제목 없음
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) {
                  return const Text(
                    '0',
                    style: TextStyle(color: AppColors.darkGray, fontSize: 12),
                  );
                }

                // 1만 단위로 표시 (10000 -> 1만)
                if (value % 10000 == 0) {
                  return Text(
                    '${(value / 10000).toInt()}만',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 12,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(chartData.length, (index) {
          return BarChartGroupData(
            x: index,
            groupVertically: false,
            barRods: [
              // 우리 그룹
              BarChartRodData(
                toY: chartData[index]['our'].toDouble(),
                color: AppColors.primary,
                width: 60,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              // 다른 그룹
              BarChartRodData(
                toY: chartData[index]['other'].toDouble(),
                color: AppColors.lightGray,
                width: 60,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
            barsSpace: 20,
          );
        }),
      ),
    );
  }

  // 통계 열
  Widget _buildStatColumn({
    required String title,
    required String avgSpending,
    required String totalSpending,
    required String transactionCount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatItem('평균 지출', avgSpending),
        const SizedBox(height: 8),
        _buildStatItem('총 지출', totalSpending),
        const SizedBox(height: 8),
        _buildStatItem('결제 횟수', transactionCount),
      ],
    );
  }

  // 통계 항목
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
}