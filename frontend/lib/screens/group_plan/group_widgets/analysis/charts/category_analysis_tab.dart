// lib/screens/group_plan/group_widgets/analysis/charts/category_analysis_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/category_analysis_model.dart';

import 'common_widgets.dart';

class CategoryAnalysisTab extends StatelessWidget {
  final CategoryAnalysisResult? categoryResult;

  const CategoryAnalysisTab({Key? key, required this.categoryResult})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카테고리별 분석 데이터가 없는 경우
    if (categoryResult == null) {
      return const Center(child: Text('카테고리별 소비 패턴 데이터가 없습니다'));
    }

    final data = categoryResult!;

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
            title: '카테고리별 소비 인사이트',
            insights: _getCategoryInsights(data),
          ),

          const SizedBox(height: 24),

          // 카테고리별 지출 비율 (파이 차트)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 지출 비율',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 차트 영역
                  data.categorySpending.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text('카테고리 지출 데이터가 없습니다'),
                        ),
                      )
                      : SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildCategoryPieChart(data),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: _buildCategoryLegend(data),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 카테고리별 평균 지출 차트
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 평균 지출',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 차트 영역
                  data.categorySpending.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text('카테고리 지출 데이터가 없습니다'),
                        ),
                      )
                      : SizedBox(
                        height: 300,
                        child: _buildCategoryAverageChart(data),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 카테고리별 데이터 테이블
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 상세 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 테이블 영역
                  _buildCategorySummaryTable(data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리별 인사이트 생성
  List<String> _getCategoryInsights(CategoryAnalysisResult data) {
    List<String> insights = [];

    // 가장 지출이 많은 카테고리
    if (data.categorySpending.isNotEmpty) {
      var entries = data.categorySpending.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));

      String topCategory = entries.first.key;
      int topSpending = entries.first.value;
      double percentage = data.getCategorySpendingPercentage(topCategory);

      insights.add(
        '가장 지출이 많은 카테고리는 \'$topCategory\'로, 총 지출의 ${percentage.toStringAsFixed(1)}%(${NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0).format(topSpending)})를 차지합니다.',
      );
    }

    // 가장 방문 횟수가 많은 카테고리
    if (data.categoryVisits.isNotEmpty) {
      var entries = data.categoryVisits.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));

      String topCategory = entries.first.key;
      int visits = entries.first.value;
      double percentage = visits / data.totalVisits * 100;

      insights.add(
        '가장 자주 방문하는 카테고리는 \'$topCategory\'로, 총 ${visits}회(${percentage.toStringAsFixed(1)}%) 방문했습니다.',
      );
    }

    // 1회 방문당 지출이 가장 높은 카테고리
    if (data.categorySpending.isNotEmpty && data.categoryVisits.isNotEmpty) {
      double highestAvg = 0;
      String highestAvgCategory = '';

      for (var category in data.categories) {
        double avg = data.getCategoryAverageSpending(category);
        if (avg > highestAvg) {
          highestAvg = avg;
          highestAvgCategory = category;
        }
      }

      if (highestAvgCategory.isNotEmpty) {
        insights.add(
          '1회 방문당 지출이 가장 높은 카테고리는 \'$highestAvgCategory\'로, 평균 ${NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0).format(highestAvg)}입니다.',
        );
      }
    }

    // 전체 요약
    insights.add(
      '총 ${data.totalVisits}회 방문, 총 지출액은 ${NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0).format(data.totalAmount)}입니다.',
    );

    return insights;
  }

  // 카테고리별 지출 파이 차트
  Widget _buildCategoryPieChart(CategoryAnalysisResult data) {
    // 데이터가 없는 경우
    if (data.categorySpending.isEmpty) {
      return const Center(child: Text('표시할 데이터가 없습니다'));
    }

    // 색상 리스트 (카테고리별 색상)
    final List<Color> colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.primaryDark,
      AppColors.orange,
      AppColors.red,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      // 추가 색상들...
    ];

    // 카테고리별 지출액 정렬 (내림차순)
    List<MapEntry<String, int>> sortedEntries =
        data.categorySpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // 파이 차트 섹션 데이터 생성
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      String category = sortedEntries[i].key;
      int spending = sortedEntries[i].value;
      double percentage = data.getCategorySpendingPercentage(category);

      // 색상 인덱스 (순환)
      int colorIndex = i % colors.length;

      sections.add(
        PieChartSectionData(
          value: spending.toDouble(),
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          color: colors[colorIndex],
          radius: 110,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 10, sectionsSpace: 2),
    );
  }

  // 카테고리별 범례
  Widget _buildCategoryLegend(CategoryAnalysisResult data) {
    // 색상 리스트
    final List<Color> colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.primaryDark,
      AppColors.orange,
      AppColors.red,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    // 카테고리별 지출액 정렬 (내림차순)
    List<MapEntry<String, int>> sortedEntries =
        data.categorySpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // 범례 생성
    List<Widget> legends = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      String category = sortedEntries[i].key;
      int spending = sortedEntries[i].value;
      double percentage = data.getCategorySpendingPercentage(category);
      int colorIndex = i % colors.length;

      legends.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[colorIndex],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: legends,
      ),
    );
  }

  // 카테고리별 평균 지출 차트
  Widget _buildCategoryAverageChart(CategoryAnalysisResult data) {
    // 카테고리별 평균 지출 계산
    Map<String, double> categoryAvgs = {};
    for (var category in data.categories) {
      categoryAvgs[category] = data.getCategoryAverageSpending(category);
    }

    // 평균 지출 기준 정렬 (내림차순)
    List<MapEntry<String, double>> sortedEntries =
        categoryAvgs.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // 가장 큰 값의 1.2배를 Y축 최대값으로 설정
    double maxY =
        sortedEntries.isEmpty ? 50000 : sortedEntries.first.value * 1.2;

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
              String category = sortedEntries[group.x.toInt()].key;
              double amount = rod.toY;

              return BarTooltipItem(
                '${category}: ${formatCurrency.format(amount)}',
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
                if (value.toInt() >= sortedEntries.length) {
                  return const SizedBox.shrink();
                }

                String category = sortedEntries[value.toInt()].key;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
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
        barGroups: List.generate(sortedEntries.length, (index) {
          String category = sortedEntries[index].key;
          double avgSpending = sortedEntries[index].value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: avgSpending,
                color: AppColors.primary,
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 카테고리별 데이터 테이블
  Widget _buildCategorySummaryTable(CategoryAnalysisResult data) {
    // 평균 지출 기준 정렬 (내림차순)
    List<String> categories = data.categories.toList();
    categories.sort(
      (a, b) => data.categorySpending[b]!.compareTo(data.categorySpending[a]!),
    );

    // 금액 포맷터
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    // 퍼센트 포맷터
    final formatPercent = NumberFormat.percentPattern('ko_KR')
      ..maximumFractionDigits = 1;

    return Table(
      border: TableBorder.all(
        color: AppColors.lightGray.withOpacity(0.5),
        width: 1,
        style: BorderStyle.solid,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.2), // 카테고리
        1: FlexColumnWidth(1), // 지출액
        2: FlexColumnWidth(1), // 방문수
        3: FlexColumnWidth(1), // 평균
        4: FlexColumnWidth(0.8), // 비율
      },
      children: [
        // 테이블 헤더
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
          ),
          children: [
            CommonWidgets.buildTableCell('카테고리', isHeader: true),
            CommonWidgets.buildTableCell('지출액', isHeader: true),
            CommonWidgets.buildTableCell('방문수', isHeader: true),
            CommonWidgets.buildTableCell('평균', isHeader: true),
            CommonWidgets.buildTableCell('비율', isHeader: true),
          ],
        ),

        // 데이터 행
        ...categories.map((category) {
          int spending = data.categorySpending[category] ?? 0;
          int visits = data.categoryVisits[category] ?? 0;
          double average = visits > 0 ? spending / visits : 0;
          double percentage =
              data.getCategorySpendingPercentage(category) / 100;

          return TableRow(
            children: [
              // 카테고리명
              CommonWidgets.buildTableCell(
                category,
                fontWeight: FontWeight.bold,
              ),

              // 총 지출액
              CommonWidgets.buildTableCell(
                formatCurrency.format(spending),
                textAlign: TextAlign.right,
              ),

              // 방문 횟수
              CommonWidgets.buildTableCell(
                '$visits회',
                textAlign: TextAlign.right,
              ),

              // 평균 지출액
              CommonWidgets.buildTableCell(
                formatCurrency.format(average),
                textAlign: TextAlign.right,
              ),

              // 비율
              CommonWidgets.buildTableCell(
                formatPercent.format(percentage),
                textAlign: TextAlign.right,
              ),
            ],
          );
        }).toList(),

        // 합계 행
        TableRow(
          decoration: BoxDecoration(color: AppColors.verylightGray),
          children: [
            CommonWidgets.buildTableCell('합계', fontWeight: FontWeight.bold),
            CommonWidgets.buildTableCell(
              formatCurrency.format(data.totalAmount),
              textAlign: TextAlign.right,
              fontWeight: FontWeight.bold,
            ),
            CommonWidgets.buildTableCell(
              '${data.totalVisits}회',
              textAlign: TextAlign.right,
              fontWeight: FontWeight.bold,
            ),
            CommonWidgets.buildTableCell(
              formatCurrency.format(data.totalAmount / data.totalVisits),
              textAlign: TextAlign.right,
              fontWeight: FontWeight.bold,
            ),
            CommonWidgets.buildTableCell(
              '100%',
              textAlign: TextAlign.right,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}
