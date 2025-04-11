// TODO Implement this library.
// lib/screens/group_plan/group_widgets/analysis/charts/day_of_week_comparison_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';

import 'common_widgets.dart';

class DayOfWeekComparisonTab extends StatelessWidget {
  final GroupAnalysisResult? analysisResult;

  const DayOfWeekComparisonTab({Key? key, required this.analysisResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 요일별 분석 데이터가 없는 경우
    if (analysisResult?.analyses['day_of_week_comparison'] == null) {
      return const Center(child: Text('요일별 소비 패턴 데이터가 없습니다'));
    }

    final dayOfWeekComparison = analysisResult!.analyses['day_of_week_comparison'] as DayOfWeekComparison;
    final data = dayOfWeekComparison.data;
    
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
            title: '요일별 소비 인사이트',
            insights: _getDayOfWeekInsights(data),
          ),

          const SizedBox(height: 24),

          // 요일별 평균 지출 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '요일별 평균 지출',
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
                    child: _buildDayOfWeekComparisonChart(data),
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

          // 요일별 방문 횟수 비교 테이블
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '요일별 방문 및 지출 요약',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 테이블 영역
                  _buildDayOfWeekSummaryTable(data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 요일별 인사이트 생성
  List<String> _getDayOfWeekInsights(List<DayOfWeekComparisonData> data) {
    List<String> insights = [];
    
    // 우리 그룹과 다른 그룹 데이터 분리
    var ourGroupData = data.where((item) => item.groupType == '우리 그룹').toList();
    var otherGroupData = data.where((item) => item.groupType == '다른 그룹').toList();
    
    // 가장 많은 방문 요일 찾기
    if (ourGroupData.isNotEmpty) {
      var mostVisitedDay = ourGroupData.reduce(
        (a, b) => a.visitCount > b.visitCount ? a : b
      );
      
      insights.add('우리 그룹이 가장 많이 방문하는 요일은 ${getDayOfWeekName(mostVisitedDay.dayOfWeek)}입니다 (${mostVisitedDay.visitCount}회).');
    }
    
    // 가장 지출이 많은 요일 찾기
    if (ourGroupData.isNotEmpty) {
      var highestSpendingDay = ourGroupData.reduce(
        (a, b) => a.avgSpending > b.avgSpending ? a : b
      );
      
      insights.add('${getDayOfWeekName(highestSpendingDay.dayOfWeek)}에 평균 지출이 가장 높습니다 (${NumberFormat.currency(
        locale: 'ko_KR',
        symbol: '₩',
        decimalDigits: 0,
      ).format(highestSpendingDay.avgSpending)}).');
    }
    
    // 주중/주말 패턴 분석
    if (ourGroupData.isNotEmpty) {
      // 주중 (월-금)
      var weekdayData = ourGroupData.where((item) => 
        item.dayOfWeek >= 1 && item.dayOfWeek <= 5).toList();
        
      // 주말 (토-일)
      var weekendData = ourGroupData.where((item) => 
        item.dayOfWeek >= 6 && item.dayOfWeek <= 7).toList();
        
      if (weekdayData.isNotEmpty && weekendData.isNotEmpty) {
        double weekdayAvg = weekdayData.map((e) => e.avgSpending).reduce((a, b) => a + b) / weekdayData.length;
        double weekendAvg = weekendData.map((e) => e.avgSpending).reduce((a, b) => a + b) / weekendData.length;
        
        double ratio = weekendAvg / weekdayAvg;
        
        insights.add('주말 평균 지출(${NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        ).format(weekendAvg)})은 주중(${NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        ).format(weekdayAvg)})보다 ${(ratio * 100 - 100).abs().toStringAsFixed(1)}% ${ratio > 1 ? '높습니다' : '낮습니다'}.');
      }
    }
    
    return insights;
  }

// 요일별 평균 지출 차트
  Widget _buildDayOfWeekComparisonChart(List<DayOfWeekComparisonData> data) {
    // 요일별로 데이터 정리
    Map<int, Map<String, double>> dailyData = {};
    
    for (var item in data) {
      if (!dailyData.containsKey(item.dayOfWeek)) {
        dailyData[item.dayOfWeek] = {};
      }
      dailyData[item.dayOfWeek]![item.groupType] = item.avgSpending;
    }
    
    // 요일 순으로 정렬 (1: 월요일 ~ 7: 일요일)
    List<int> sortedDays = dailyData.keys.toList()..sort();
    
    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    double maxY = 0;
    for (var item in data) {
      if (item.avgSpending > maxY) {
        maxY = item.avgSpending;
      }
    }
    maxY *= 1.2;
    
    // 금액 포맷터
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
              int dayOfWeek = sortedDays[group.x.toInt()];
              String dayName = getDayOfWeekName(dayOfWeek);
              double amount = rod.toY;
              
              return BarTooltipItem(
                '$dayName $groupType: ${formatCurrency.format(amount)}',
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
                if (value.toInt() >= sortedDays.length) {
                  return const SizedBox.shrink();
                }
                
                int dayOfWeek = sortedDays[value.toInt()];
                String dayName = getDayOfWeekName(dayOfWeek).substring(0, 1); // 첫 글자만
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayName,
                    style: TextStyle(
                      color: dayOfWeek >= 6 ? AppColors.red : AppColors.darkGray, // 주말은 빨간색
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
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) {
                  return const Text(
                    '0',
                    style: TextStyle(color: AppColors.darkGray, fontSize: 10),
                  );
                }

                // 1만 단위로 표시 (10000 -> 1만)
                if (value % 10000 == 0) {
                  return Text(
                    '${(value / 10000).toInt()}만',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 10,
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
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(sortedDays.length, (index) {
          int dayOfWeek = sortedDays[index];
          var dayData = dailyData[dayOfWeek]!;
          
          // 우리 그룹과 다른 그룹 데이터
          double ourGroupValue = dayData['우리 그룹'] ?? 0;
          double otherGroupValue = dayData['다른 그룹'] ?? 0;
          
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

  // 요일별 방문 및 지출 요약 테이블
  Widget _buildDayOfWeekSummaryTable(List<DayOfWeekComparisonData> data) {
    // 요일별로, 그룹 타입별로 데이터 정리
    Map<int, Map<String, DayOfWeekComparisonData>> organizedData = {};
    
    for (var item in data) {
      if (!organizedData.containsKey(item.dayOfWeek)) {
        organizedData[item.dayOfWeek] = {};
      }
      organizedData[item.dayOfWeek]![item.groupType] = item;
    }
    
    // 요일 순으로 정렬
    List<int> sortedDays = organizedData.keys.toList()..sort();
    
    // 금액 포맷터
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );
    
    return Table(
      border: TableBorder.all(
        color: AppColors.lightGray.withOpacity(0.5),
        width: 1,
        style: BorderStyle.solid,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.2), // 요일
        1: FlexColumnWidth(2), // 우리 그룹
        2: FlexColumnWidth(2), // 다른 그룹
      },
      children: [
        // 테이블 헤더
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
          ),
          children: [
            CommonWidgets.buildTableCell('요일', isHeader: true),
            CommonWidgets.buildTableCell('우리 그룹', isHeader: true),
            CommonWidgets.buildTableCell('다른 그룹', isHeader: true),
          ],
        ),
        
        // 데이터 행
        ...sortedDays.map((day) {
          // 각 요일별 우리 그룹과 다른 그룹 데이터
          var dayData = organizedData[day]!;
          var ourGroup = dayData['우리 그룹'];
          var otherGroup = dayData['다른 그룹'];
          
          return TableRow(
            decoration: BoxDecoration(
              color: day >= 6 
                  ? AppColors.noticeMemoRed.withOpacity(0.1) // 주말 (토, 일)
                  : Colors.white, // 평일
            ),
            children: [
              // 요일
              CommonWidgets.buildTableCell(
                getDayOfWeekName(day),
                textColor: day >= 6 ? AppColors.red : null,
                fontWeight: FontWeight.bold,
              ),
              
              // 우리 그룹
              CommonWidgets.buildTableCell(
                ourGroup != null
                    ? '${formatCurrency.format(ourGroup.avgSpending)}\n(${ourGroup.visitCount}회)'
                    : '-',
                textAlign: TextAlign.right,
              ),
              
              // 다른 그룹
              CommonWidgets.buildTableCell(
                otherGroup != null
                    ? '${formatCurrency.format(otherGroup.avgSpending)}\n(${otherGroup.visitCount}회)'
                    : '-',
                textAlign: TextAlign.right,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}