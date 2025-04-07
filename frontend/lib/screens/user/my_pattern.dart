import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:intl/intl.dart';

class DataVizPage extends StatefulWidget {
  const DataVizPage({Key? key}) : super(key: key);

  @override
  State<DataVizPage> createState() => _DataVizPageState();
}

class _DataVizPageState extends State<DataVizPage> {
  final UserService _userService = UserService(userProvider: UserProvider());
  Map<String, dynamic>? categoryData;
  bool isLoading = true;
  String errorMessage = '';

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
        errorMessage = '';
      });
    } catch (e) {
      debugPrint('getCategoryAnalysis 에러: $e');
      setState(() {
        errorMessage = '서버와의 통신에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '소비 패턴 분석',
        style: TextStyle(color: AppColors.darkGray),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGray),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '데이터를 불러오는 중입니다...',
              style: TextStyle(color: AppColors.darkGray, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final data = categoryData ?? _getExampleData();
    final isExampleData = categoryData == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isExampleData)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.darkGray,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '서버와의 통신에 문제가 있어 예시 데이터를 보여드립니다.',
                          style: TextStyle(
                            color: AppColors.darkGray.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          _buildCategoryChart(data),
        ],
      ),
    );
  }

  Map<String, dynamic> _getExampleData() {
    return {
      'categories': ['양식', '일식', '한식', '디저트', '분식'],
      'amounts': [80000, 50000, 70000, 90000, 60000],
    };
  }

  Widget _buildCategoryChart(Map<String, dynamic> data) {
    final categories = data['categories'] as List<dynamic>;
    final amounts = data['amounts'] as List<dynamic>;

    double maxY = amounts
        .map((amount) => double.tryParse(amount.toString()) ?? 0.0)
        .reduce((max, value) => value > max ? value : max);

    return _buildChartCard(
      title: '카테고리별 지출',
      maxY: maxY,
      buildBarGroups:
          () => List.generate(
            categories.length,
            (index) => _buildBarGroup(
              x: index,
              y: double.tryParse(amounts[index].toString()) ?? 0.0,
            ),
          ),
      getTitleText: (value) => categories[value.toInt()].toString(),
    );
  }

  Widget _buildChartCard({
    required String title,
    required double maxY,
    required List<BarChartGroupData> Function() buildBarGroups,
    required String Function(double) getTitleText,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.1,
                  barGroups: buildBarGroups(),
                  titlesData: _buildTitlesData(getTitleText),
                  gridData: _buildGridData(maxY),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup({required int x, required double y}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

FlTitlesData _buildTitlesData(String Function(double) getTitleText) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (double value, TitleMeta meta) {
          return SideTitleWidget(
            meta: meta, // TitleMeta 객체 전체를 전달
            space: 8,
            child: Text(
              getTitleText(value),
              style: const TextStyle(
                color: AppColors.darkGray,
                fontSize: 12,
              ),
            ),
          );
        },
        reservedSize: 30,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (double value, TitleMeta meta) {
          // 0은 그냥 0으로 표시
          if (value == 0) {
            return SideTitleWidget(
              meta: meta, // TitleMeta 객체 전체를 전달
              space: 8,
              child: const Text(
                '0',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
              ),
            );
          }
          
          // 1만 단위로 표시할 때만 보여주기
          if (value % 10000 == 0) {
            return SideTitleWidget(
              meta: meta, // TitleMeta 객체 전체를 전달
              space: 8,
              child: Text(
                '${(value / 10000).toStringAsFixed(0)}만원',
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
              ),
            );
          }
          
          // 다른 값은 빈 위젯 반환
          return const SizedBox.shrink();
        },
        reservedSize: 50,
      ),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
}

  FlGridData _buildGridData(double maxY) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: maxY / 5,
      getDrawingHorizontalLine:
          (value) => FlLine(color: AppColors.lightGray, strokeWidth: 1),
    );
  }
}
