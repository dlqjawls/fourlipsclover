import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/my_pattern.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:intl/intl.dart';

class ConsumptionChart extends StatefulWidget {
  const ConsumptionChart({super.key});

  @override
  State<ConsumptionChart> createState() => _ConsumptionChartState();
}

class _ConsumptionChartState extends State<ConsumptionChart> {
  final UserService _userService = UserService(userProvider: UserProvider());
  Map<String, dynamic>? categoryData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final startDate = DateFormat(
        'yyyy-MM-dd',
      ).format(now.subtract(const Duration(days: 30)));
      final endDate = DateFormat('yyyy-MM-dd').format(now);

      final data = await _userService.getCategoryAnalysis(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        categoryData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('getCategoryAnalysis 에러: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              '데이터를 불러오는 중입니다...',
              style: TextStyle(color: AppColors.darkGray, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final data = categoryData ?? _getExampleData();
    final isExampleData = categoryData == null;

    return Column(
      children: [
        if (isExampleData)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.darkGray,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '서버와의 통신에 문제가 있어 예시 데이터를 보여드립니다.',
                    style: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataVizPage()),
            );
          },
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildChart(data),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getExampleData() {
    return {
      'categories': ['양식', '일식', '한식', '디저트', '분식'],
      'amounts': [80000, 50000, 70000, 90000, 60000],
    };
  }

  Widget _buildChart(Map<String, dynamic> data) {
    final categories = data['categories'] as List<dynamic>;
    final amounts = data['amounts'] as List<dynamic>;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            amounts
                .map((amount) => double.tryParse(amount.toString()) ?? 0.0)
                .reduce((max, value) => value > max ? value : max) *
            1.1,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                );
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    categories[value.toInt()].toString(),
                    style: style,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(
          categories.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: double.tryParse(amounts[index].toString()) ?? 0.0,
                color: AppColors.primary,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
