// TODO Implement this library.
// lib/screens/group_plan/group_widgets/analysis/charts/time_comparison_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';

import 'common_widgets.dart';

class TimeComparisonTab extends StatelessWidget {
  final GroupAnalysisResult? analysisResult;

  const TimeComparisonTab({Key? key, required this.analysisResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 시간대별 분석 데이터가 없는 경우
    if (analysisResult?.analyses['time_comparison'] == null) {
      return const Center(child: Text('시간대별 소비 패턴 데이터가 없습니다'));
    }

    final timeComparison = analysisResult!.analyses['time_comparison'] as TimeComparison;
    final data = timeComparison.data;
    
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
            title: '시간대별 소비 인사이트',
            insights: _getTimeInsights(data),
          ),

          const SizedBox(height: 24),

          // 시간대별 평균 지출 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시간대별 평균 지출',
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
                    child: _buildTimeComparisonChart(data),
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

          // 시간대별 방문 횟수 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시간대별 방문 횟수',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Text(
                    '각 시간대별 방문 빈도',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 차트 영역
                  SizedBox(
                    height: 300,
                    child: _buildTimeVisitCountChart(data),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간대별 인사이트 생성
  List<String> _getTimeInsights(List<TimeComparisonData> data) {
    List<String> insights = [];
    
    // 우리 그룹과 다른 그룹 데이터 분리
    var ourGroupData = data.where((item) => item.groupType == '우리 그룹').toList();
    var otherGroupData = data.where((item) => item.groupType == '다른 그룹').toList();
    
    // 가장 많은 방문 시간대 찾기
    if (ourGroupData.isNotEmpty) {
      var mostVisitedHour = ourGroupData.reduce(
        (a, b) => a.visitCount > b.visitCount ? a : b
      );
      
      insights.add('우리 그룹이 가장 많이 방문하는 시간대는 ${mostVisitedHour.hourOfDay}시입니다 (${mostVisitedHour.visitCount}회).');
    }
    
    // 가장 지출이 많은 시간대 찾기
    if (ourGroupData.isNotEmpty) {
      var highestSpendingHour = ourGroupData.reduce(
        (a, b) => a.avgSpending > b.avgSpending ? a : b
      );
      
      insights.add('${highestSpendingHour.hourOfDay}시에 평균 지출이 가장 높습니다 (${NumberFormat.currency(
        locale: 'ko_KR',
        symbol: '₩',
        decimalDigits: 0,
      ).format(highestSpendingHour.avgSpending)}).');
    }
    
    // 식사 시간대 패턴 분석
    if (ourGroupData.isNotEmpty) {
      // 점심 시간대 (11-14시)
      var lunchData = ourGroupData.where((item) => 
        item.hourOfDay >= 11 && item.hourOfDay <= 14).toList();
        
      if (lunchData.isNotEmpty) {
        double lunchAvg = lunchData.map((e) => e.avgSpending).reduce((a, b) => a + b) / lunchData.length;
        insights.add('점심 시간대(11-14시)의 평균 지출은 ${NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        ).format(lunchAvg)}입니다.');
      }
      
      // 저녁 시간대 (17-21시)
      var dinnerData = ourGroupData.where((item) => 
        item.hourOfDay >= 17 && item.hourOfDay <= 21).toList();
        
      if (dinnerData.isNotEmpty) {
        double dinnerAvg = dinnerData.map((e) => e.avgSpending).reduce((a, b) => a + b) / dinnerData.length;
        insights.add('저녁 시간대(17-21시)의 평균 지출은 ${NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        ).format(dinnerAvg)}입니다.');
      }
    }
    
    return insights;
  }

  // 시간대별 평균 지출 차트
  Widget _buildTimeComparisonChart(List<TimeComparisonData> data) {
    // 시간대별로 데이터 정리
    Map<int, Map<String, double>> hourlyData = {};
    
    for (var item in data) {
      if (!hourlyData.containsKey(item.hourOfDay)) {
        hourlyData[item.hourOfDay] = {};
      }
      hourlyData[item.hourOfDay]![item.groupType] = item.avgSpending;
    }
    
    // 시간 순으로 정렬
    List<int> sortedHours = hourlyData.keys.toList()..sort();
    
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
    
    // 우리 그룹과 다른 그룹의 데이터 포인트 생성
    List<FlSpot> ourGroupSpots = [];
    List<FlSpot> otherGroupSpots = [];
    
    for (int i = 0; i < 24; i++) {
      var hourData = hourlyData[i];
      
      if (hourData != null && hourData.containsKey('우리 그룹')) {
        ourGroupSpots.add(FlSpot(i.toDouble(), hourData['우리 그룹']!));
      } else {
        // 데이터가 없으면 0으로 처리 (연결선 유지를 위해)
        ourGroupSpots.add(FlSpot(i.toDouble(), 0));
      }
      
      if (hourData != null && hourData.containsKey('다른 그룹')) {
        otherGroupSpots.add(FlSpot(i.toDouble(), hourData['다른 그룹']!));
      } else {
        otherGroupSpots.add(FlSpot(i.toDouble(), 0));
      }
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: true,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                // 3시간 간격으로만 표시
                if (value.toInt() % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}시',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
        ),
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => AppColors.darkGray,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                String groupType = spot.barIndex == 0 ? '우리 그룹' : '다른 그룹';
                int hour = spot.x.toInt();
                double amount = spot.y;
                
                return LineTooltipItem(
                  '$hour시 $groupType: ${formatCurrency.format(amount)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // 우리 그룹 라인
          LineChartBarData(
            spots: ourGroupSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
              checkToShowDot: (spot, barData) {
                // 데이터가 0인 경우 점 표시 안함
                return spot.y > 0;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          // 다른 그룹 라인
          LineChartBarData(
            spots: otherGroupSpots,
            isCurved: true,
            color: AppColors.lightGray,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.lightGray,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
              checkToShowDot: (spot, barData) {
                // 데이터가 0인 경우 점 표시 안함
                return spot.y > 0;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.lightGray.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  // 시간대별 방문 횟수 차트
  Widget _buildTimeVisitCountChart(List<TimeComparisonData> data) {
    // 시간대별로 데이터 정리
    Map<int, Map<String, int>> hourlyData = {};
    
    for (var item in data) {
      if (!hourlyData.containsKey(item.hourOfDay)) {
        hourlyData[item.hourOfDay] = {};
      }
      hourlyData[item.hourOfDay]![item.groupType] = item.visitCount;
    }
    
    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    int maxVisits = 0;
    for (var item in data) {
      if (item.visitCount > maxVisits) {
        maxVisits = item.visitCount;
      }
    }
    double maxY = maxVisits * 1.2;
    
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
              int hour = group.x.toInt();
              int count = rod.toY.toInt();
              
              return BarTooltipItem(
                '$hour시 $groupType: $count회',
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
                // 3시간 간격으로만 표시
                if (value.toInt() % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}시',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 100 == 0 || value == 0) {
                  return Text(
                    value.toInt().toString(),
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
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(24, (hour) {
          var hourData = hourlyData[hour];
          
          // 우리 그룹과 다른 그룹 데이터
          int ourGroupValue = hourData != null ? (hourData['우리 그룹'] ?? 0) : 0;
          int otherGroupValue = hourData != null ? (hourData['다른 그룹'] ?? 0) : 0;
          
          return BarChartGroupData(
            x: hour,
            groupVertically: false,
            barRods: [
              // 우리 그룹
              if (ourGroupValue > 0)
                BarChartRodData(
                  toY: ourGroupValue.toDouble(),
                  color: AppColors.primary,
                  width: 8,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              // 다른 그룹
              if (otherGroupValue > 0)
                BarChartRodData(
                  toY: otherGroupValue.toDouble(),
                  color: AppColors.lightGray,
                  width: 8,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
            ],
            barsSpace: 4,
          );
        }),
      ),
    );
  }
}