// lib/screens/group_plan/plan_widgets/group_expenses_analysis_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme.dart';

class GroupExpensesAnalysisView extends StatefulWidget {
  final int groupId;

  const GroupExpensesAnalysisView({Key? key, required this.groupId})
    : super(key: key);

  @override
  State<GroupExpensesAnalysisView> createState() =>
      _GroupExpensesAnalysisViewState();
}

class _GroupExpensesAnalysisViewState extends State<GroupExpensesAnalysisView> {
  // 선택된 필터 (주간/월간/연간)
  String _selectedPeriod = '주간';

  // 더미 데이터 - 여행별 요일당 지출
  final Map<String, List<Map<String, dynamic>>> _dummyExpenseData = {
    '제주도 여행': [
      {'day': '월', 'date': '4/8', 'amount': 35000},
      {'day': '화', 'date': '4/9', 'amount': 78000},
      {'day': '수', 'date': '4/10', 'amount': 62000},
      {'day': '목', 'date': '4/11', 'amount': 55000},
      {'day': '금', 'date': '4/12', 'amount': 94000},
      {'day': '토', 'date': '4/13', 'amount': 115000},
      {'day': '일', 'date': '4/14', 'amount': 42000},
    ],
    '부산 여행': [
      {'day': '금', 'date': '3/22', 'amount': 42000},
      {'day': '토', 'date': '3/23', 'amount': 97000},
      {'day': '일', 'date': '3/24', 'amount': 65000},
    ],
    '강원도 여행': [
      {'day': '토', 'date': '2/10', 'amount': 83000},
      {'day': '일', 'date': '2/11', 'amount': 76000},
    ],
  };

  // 선택된 여행 (기본값: 전체)
  String _selectedTrip = '전체';

  // 더미 데이터 - 요일별 평균 지출
  final List<Map<String, dynamic>> _dummyDayAverages = [
    {'day': '월', 'amount': 35000},
    {'day': '화', 'amount': 78000},
    {'day': '수', 'amount': 62000},
    {'day': '목', 'amount': 55000},
    {'day': '금', 'amount': 68000},
    {'day': '토', 'amount': 98333},
    {'day': '일', 'amount': 61000},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 및 필터
          _buildTitleAndFilters(),

          const SizedBox(height: 24),

          // 막대 그래프 카드
          _buildBarChartCard(),

          const SizedBox(height: 24),

          // 통계 정보 카드
          _buildStatsCard(),
        ],
      ),
    );
  }

  // 타이틀 및 필터 위젯
  Widget _buildTitleAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀
        const Text(
          '그룹 지출 분석',
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),

        const SizedBox(height: 16),

        // 필터 옵션
        Row(
          children: [
            // 기간 필터
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        ['주간', '월간', '연간'].map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 여행 필터
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTrip,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        ['전체', ..._dummyExpenseData.keys.toList()].map((
                          String trip,
                        ) {
                          return DropdownMenuItem<String>(
                            value: trip,
                            child: Text(trip),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTrip = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 막대 그래프 카드 위젯
  Widget _buildBarChartCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '요일별 지출 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedTrip == '전체'
                  ? '모든 여행의 요일별 평균 지출'
                  : '$_selectedTrip의 요일별 지출',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 20),
            SizedBox(height: 300, child: _buildBarChart()),
          ],
        ),
      ),
    );
  }

  // 막대 그래프 구현
  Widget _buildBarChart() {
    // 데이터 준비
    List<Map<String, dynamic>> chartData;

    if (_selectedTrip == '전체') {
      // 전체 선택 시 요일별 평균 데이터 사용
      chartData = _dummyDayAverages;
    } else {
      // 특정 여행 선택 시 해당 여행 데이터 사용
      chartData = _dummyExpenseData[_selectedTrip] ?? [];
    }

    // 빈 데이터 처리
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          '표시할 데이터가 없습니다.',
          style: TextStyle(color: AppColors.mediumGray),
        ),
      );
    }

    // 가장 높은 금액의 1.2배를 최대값으로 설정
    double maxY = 0;
    for (var data in chartData) {
      if (data['amount'] > maxY) {
        maxY = data['amount'].toDouble();
      }
    }
    maxY = maxY * 1.2;

    // 숫자 포맷터 (₩10,000 형식)
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
              return BarTooltipItem(
                formatCurrency.format(chartData[groupIndex]['amount']),
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
              reservedSize: 36,
              getTitlesWidget: (double value, TitleMeta meta) {
                // 전체 선택 시 요일만, 개별 여행 선택 시 요일+날짜
                String title;
                if (value.toInt() >= chartData.length) {
                  return const SizedBox.shrink();
                }

                if (_selectedTrip == '전체') {
                  title = chartData[value.toInt()]['day'];
                } else {
                  title =
                      '${chartData[value.toInt()]['day']}\n${chartData[value.toInt()]['date']}';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    title,
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
          final data = chartData[index];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['amount'].toDouble(),
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

  // 통계 정보 카드 위젯
  Widget _buildStatsCard() {
    // 통계 계산 (더미 데이터에서)
    int totalExpense = 0;
    int tripCount = 0;
    int dayCount = 0;

    if (_selectedTrip == '전체') {
      // 모든 여행의 데이터 합산
      for (var trip in _dummyExpenseData.entries) {
        tripCount++;
        dayCount += trip.value.length;
        for (var day in trip.value) {
          totalExpense += day['amount'] as int;
        }
      }
    } else {
      // 선택된 여행만 계산
      tripCount = 1;
      var tripData = _dummyExpenseData[_selectedTrip] ?? [];
      dayCount = tripData.length;
      for (var day in tripData) {
        totalExpense += day['amount'] as int;
      }
    }

    // 일평균 지출 계산
    int dailyAverage = dayCount > 0 ? (totalExpense / dayCount).round() : 0;

    // 금액 포맷터
    final formatCurrency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지출 요약',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),

            // 통계 항목들
            _buildStatItem(
              icon: Icons.attach_money,
              title: '총 지출액',
              value: formatCurrency.format(totalExpense),
            ),
            const Divider(height: 24),

            _buildStatItem(
              icon: Icons.calendar_today,
              title: _selectedTrip == '전체' ? '여행 수' : '여행 기간',
              value: _selectedTrip == '전체' ? '$tripCount개' : '$dayCount일',
            ),
            const Divider(height: 24),

            _buildStatItem(
              icon: Icons.trending_up,
              title: '일평균 지출',
              value: formatCurrency.format(dailyAverage),
            ),
          ],
        ),
      ),
    );
  }

  // 통계 항목 위젯
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
