// TODO Implement this library.
// lib/screens/group_plan/group_widgets/analysis/charts/personnel_comparison_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';

import 'common_widgets.dart';

class PersonnelComparisonTab extends StatelessWidget {
  final GroupAnalysisResult? analysisResult;

  const PersonnelComparisonTab({Key? key, required this.analysisResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 인원별 분석 데이터가 없는 경우
    if (analysisResult?.analyses['personnel_comparison'] == null) {
      return const Center(child: Text('인원별 소비 패턴 데이터가 없습니다'));
    }

    final personnelComparison = analysisResult!.analyses['personnel_comparison'] as PersonnelComparison;
    final data = personnelComparison.data;
    
    // 특이값 제거 (방문 인원이 비정상적으로 큰 경우)
    final filteredData = data.where((item) => item.visitedPersonnel < 10).toList();
    
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
            title: '인원별 소비 인사이트',
            insights: _getPersonnelInsights(filteredData),
          ),

          const SizedBox(height: 24),

          // 인원별 소비 비교 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '인원별 평균 지출',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 차트 영역
                  SizedBox(
                    height: 300,
                    child: _buildPersonnelComparisonChart(filteredData),
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

          // 인원별 방문 횟수 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '인원별 방문 횟수',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 차트 영역
                  SizedBox(
                    height: 300,
                    child: _buildPersonnelVisitCountChart(filteredData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 인원별 인사이트 생성
  List<String> _getPersonnelInsights(List<PersonnelComparisonData> data) {
    List<String> insights = [];
    
    // 우리 그룹과 다른 그룹 데이터 분리
    var ourGroupData = data.where((item) => item.groupType == '우리 그룹').toList();
    var otherGroupData = data.where((item) => item.groupType == '다른 그룹').toList();
    
    // 가장 많은 방문 인원 찾기
    if (ourGroupData.isNotEmpty) {
      var mostVisitedPersonnel = ourGroupData.reduce(
        (a, b) => a.visitCount > b.visitCount ? a : b
      );
      
      insights.add('우리 그룹은 ${mostVisitedPersonnel.visitedPersonnel}인 방문이 가장 많습니다 (${mostVisitedPersonnel.visitCount}회).');
    }
    
    // 1인당 평균 지출 비교
    var ourOnePersonData = ourGroupData.firstWhere(
      (item) => item.visitedPersonnel == 1,
      orElse: () => PersonnelComparisonData(
        visitedPersonnel: 1,
        groupType: '우리 그룹',
        avgSpending: 0,
        visitCount: 0,
        groupId: 0,
        timestamp: '',
        analysisType: '',
      ),
    );
    
    var otherOnePersonData = otherGroupData.firstWhere(
      (item) => item.visitedPersonnel == 1,
      orElse: () => PersonnelComparisonData(
        visitedPersonnel: 1,
        groupType: '다른 그룹',
        avgSpending: 0,
        visitCount: 0,
        groupId: 0,
        timestamp: '',
        analysisType: '',
      ),
    );
    
    if (ourOnePersonData.avgSpending > 0 && otherOnePersonData.avgSpending > 0) {
      double ratio = ourOnePersonData.avgSpending / otherOnePersonData.avgSpending;
      insights.add('1인 방문 시 우리 그룹은 다른 그룹보다 ${(ratio * 100 - 100).abs().toStringAsFixed(1)}% ${ratio > 1 ? '더 많이' : '적게'} 지출합니다.');
    }
    
    // 가장 큰 차이를 보이는 인원수 찾기
    double maxDiffRatio = 0;
    int maxDiffPersonnel = 0;
    
    for (var ourData in ourGroupData) {
      var otherData = otherGroupData.firstWhere(
        (item) => item.visitedPersonnel == ourData.visitedPersonnel,
        orElse: () => null as PersonnelComparisonData,
      );
      
      if (otherData != null && otherData.avgSpending > 0) {
        double ratio = ourData.avgSpending / otherData.avgSpending;
        double diffRatio = (ratio - 1).abs();
        
        if (diffRatio > maxDiffRatio) {
          maxDiffRatio = diffRatio;
          maxDiffPersonnel = ourData.visitedPersonnel;
        }
      }
    }
    
    if (maxDiffPersonnel > 0) {
      insights.add('${maxDiffPersonnel}인 방문 시 우리 그룹과 다른 그룹의 지출 차이가 가장 큽니다.');
    }
    
    return insights;
  }

  // 인원별 소비 비교 차트
  Widget _buildPersonnelComparisonChart(List<PersonnelComparisonData> data) {
    // 인원수별로 데이터 정리
    Map<int, Map<String, double>> groupedData = {};
    for (var item in data) {
      if (!groupedData.containsKey(item.visitedPersonnel)) {
        groupedData[item.visitedPersonnel] = {};
      }
      groupedData[item.visitedPersonnel]![item.groupType] = item.avgSpending;
    }

    // 인원수 순으로 정렬
    List<int> sortedPersonnel = groupedData.keys.toList()..sort();

    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    double maxY = 0;
    for (var item in data) {
      if (item.avgSpending > maxY) {
        maxY = item.avgSpending;
      }
    }
    maxY *= 1.2;

    // 포맷터
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(10),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String groupType = rodIndex == 0 ? '우리 그룹' : '다른 그룹';
              int personnel = sortedPersonnel[group.x.toInt()];
              double amount = rod.toY;
              
              return BarTooltipItem(
                '$personnel인 $groupType: ${formatCurrency.format(amount)}',
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
                if (value.toInt() >= sortedPersonnel.length) {
                  return const SizedBox.shrink();
                }
                
                int personnel = sortedPersonnel[value.toInt()];
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$personnel인',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
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
        barGroups: List.generate(sortedPersonnel.length, (index) {
          int personnel = sortedPersonnel[index];
          var personnelData = groupedData[personnel]!;
          
          // 우리 그룹과 다른 그룹 데이터
          double ourGroupValue = personnelData['우리 그룹'] ?? 0;
          double otherGroupValue = personnelData['다른 그룹'] ?? 0;
          
          return BarChartGroupData(
            x: index,
            groupVertically: false,
            barRods: [
              // 우리 그룹
              if (ourGroupValue > 0)
                BarChartRodData(
                  toY: ourGroupValue,
                  color: AppColors.primary,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              // 다른 그룹
              if (otherGroupValue > 0)
                BarChartRodData(
                  toY: otherGroupValue,
                  color: AppColors.lightGray,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
            ],
            barsSpace: 8,
          );
        }),
      ),
    );
  }

  // 인원별 방문 횟수 차트
  Widget _buildPersonnelVisitCountChart(List<PersonnelComparisonData> data) {
    // 데이터 정리
    Map<int, Map<String, int>> groupedData = {};
    for (var item in data) {
      if (!groupedData.containsKey(item.visitedPersonnel)) {
        groupedData[item.visitedPersonnel] = {};
      }
      groupedData[item.visitedPersonnel]![item.groupType] = item.visitCount;
    }

    // 인원수 순으로 정렬
    List<int> sortedPersonnel = groupedData.keys.toList()..sort();

    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    int maxVisitCount = 0;
    for (var item in data) {
      if (item.visitCount > maxVisitCount) {
        maxVisitCount = item.visitCount;
      }
    }
    double maxY = maxVisitCount * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(10),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String groupType = rodIndex == 0 ? '우리 그룹' : '다른 그룹';
              int personnel = sortedPersonnel[group.x.toInt()];
              int count = rod.toY.toInt();
              
              return BarTooltipItem(
                '$personnel인 $groupType: $count회',
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
                if (value.toInt() >= sortedPersonnel.length) {
                  return const SizedBox.shrink();
                }
                
                int personnel = sortedPersonnel[value.toInt()];
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$personnel인',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 50 == 0 || value == 0) {
                  return Text(
                    value.toInt().toString(),
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
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(sortedPersonnel.length, (index) {
          int personnel = sortedPersonnel[index];
          var personnelData = groupedData[personnel]!;
          
          // 우리 그룹과 다른 그룹 데이터
          int ourGroupValue = personnelData['우리 그룹'] ?? 0;
          int otherGroupValue = personnelData['다른 그룹'] ?? 0;
          
          return BarChartGroupData(
            x: index,
            groupVertically: false,
            barRods: [
              // 우리 그룹
              if (ourGroupValue > 0)
                BarChartRodData(
                  toY: ourGroupValue.toDouble(),
                  color: AppColors.primary,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              // 다른 그룹
              if (otherGroupValue > 0)
                BarChartRodData(
                  toY: otherGroupValue.toDouble(),
                  color: AppColors.lightGray,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
            ],
            barsSpace: 8,
          );
        }),
      ),
    );
  }
}