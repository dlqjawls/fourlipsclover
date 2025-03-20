import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/config/theme.dart';

class DataVizPage extends StatefulWidget {
  const DataVizPage({Key? key}) : super(key: key);

  @override
  State<DataVizPage> createState() => _DataVizPageState();
}

class _DataVizPageState extends State<DataVizPage> {
  List<Map<String, dynamic>> groupSizeData = [];
  List<Map<String, dynamic>> dayOfWeekData = [];
  bool isLoading = true;

  static const Map<String, int> dayOrder = {
    'Mon': 1,
    'Tue': 2,
    'Wed': 3,
    'Thu': 4,
    'Fri': 5,
    'Sat': 6,
    'Sun': 7,
  };

  static const Map<int, String> dayLabels = {
    1: '월',
    2: '화',
    3: '수',
    4: '목',
    5: '금',
    6: '토',
    7: '일',
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // CSV 파일 로드 및 파싱
      final groupSizeData = await _loadCSVData(
        'assets/test/spending_by_group_size.csv',
        processGroupSizeRow,
      );
      final dayOfWeekData = await _loadCSVData(
        'assets/test/spending_by_day_of_week.csv',
        processDayOfWeekRow,
      );

      setState(() {
        this.groupSizeData = groupSizeData;
        this.dayOfWeekData = dayOfWeekData;
        isLoading = false;
      });
    } catch (e) {
      print('데이터 로드 오류: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadCSVData(
    String path,
    Map<String, dynamic> Function(List<dynamic>) processRow,
  ) async {
    final String rawData = await rootBundle.loadString(path);
    final rows = const CsvToListConverter().convert(rawData);
    final List<Map<String, dynamic>> processedData = [];

    for (int i = 1; i < rows.length; i++) {
      processedData.add(processRow(rows[i]));
    }

    return processedData;
  }

  Map<String, dynamic> processGroupSizeRow(List<dynamic> row) {
    return {
      'traveler_count': int.tryParse(row[0].toString()) ?? 0,
      'transaction_count': int.tryParse(row[1].toString()) ?? 0,
      'avg_amount_per_transaction':
          double.tryParse(row[2].toString().replaceAll(',', '')) ?? 0.0,
    };
  }

  Map<String, dynamic> processDayOfWeekRow(List<dynamic> row) {
    final day = row[0].toString();
    return {
      'day_of_week': day,
      'day_order': dayOrder[day] ?? 0,
      'transaction_count': int.tryParse(row[1].toString()) ?? 0,
      'avg_amount':
          double.tryParse(row[2].toString().replaceAll(',', '')) ?? 0.0,
    };
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
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGroupSizeChart(),
          const SizedBox(height: 24),
          _buildDayOfWeekChart(),
        ],
      ),
    );
  }

  Widget _buildGroupSizeChart() {
    if (groupSizeData.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    double maxY = groupSizeData
        .map((data) => data['avg_amount_per_transaction'] as double)
        .reduce((max, value) => value > max ? value : max);

    return _buildChartCard(
      title: '인원별 평균 소비 금액',
      maxY: maxY,
      buildBarGroups:
          () =>
              groupSizeData
                  .map(
                    (data) => _buildBarGroup(
                      x: data['traveler_count'],
                      y: data['avg_amount_per_transaction'],
                    ),
                  )
                  .toList(),
      getTitleText: (value) => '${value.toInt()}명',
    );
  }

  Widget _buildDayOfWeekChart() {
    if (dayOfWeekData.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    double maxY = dayOfWeekData
        .map((data) => data['avg_amount'] as double)
        .reduce((max, value) => value > max ? value : max);

    return _buildChartCard(
      title: '요일별 평균 소비 금액',
      maxY: maxY,
      buildBarGroups:
          () =>
              dayOfWeekData
                  .map(
                    (data) => _buildBarGroup(
                      x: data['day_order'],
                      y: data['avg_amount'],
                    ),
                  )
                  .toList(),
      getTitleText: (value) => dayLabels[value.toInt()] ?? '',
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
          getTitlesWidget:
              (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  getTitleText(value),
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 12,
                  ),
                ),
              ),
          reservedSize: 30,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget:
              (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '${(value / 10000).toStringAsFixed(0)}만원',
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 12,
                  ),
                ),
              ),
          reservedSize: 50,
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
