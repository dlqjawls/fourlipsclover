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
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _userService.getCategoryAnalysis();

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
          _buildPieChart(data),
          const SizedBox(height: 24),
          _buildLegends(data),
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

  Widget _buildPieChart(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 지출',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 320,
              padding: const EdgeInsets.only(bottom: 20),
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1,
                  centerSpaceRadius: 40,
                  sections: _buildPieSections(data),
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, dynamic> data) {
    final categories = data['categories'] as List<dynamic>;
    final amounts = data['amounts'] as List<dynamic>;

    // 색상 리스트 생성
    final colors = [
      AppColors.primary, // 기본 앱 컬러
      const Color(0xfff8b250), // 주황색
      const Color(0xff845bef), // 보라색
      const Color(0xff13d38e), // 초록색
      const Color(0xfffd8c73), // 연한 빨강
    ];

    // 전체 합계 계산
    double total = 0;
    for (var amount in amounts) {
      total += (double.tryParse(amount.toString()) ?? 0.0);
    }

    return List.generate(categories.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 18 : 14;
      final double radius = isTouched ? 105 : 95;
      final double value = double.tryParse(amounts[i].toString()) ?? 0.0;

      // 비율 계산 (백분율)
      final percentage = total > 0 ? (value / total * 100) : 0;

      // 카테고리 이름 가져오기
      final categoryName = categories[i].toString();

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        badgeWidget: _getCategoryBadge(
          categoryName,
          colors[i % colors.length],
          isTouched,
        ),
        badgePositionPercentageOffset: 1.15,
      );
    });
  }

  Widget _getCategoryBadge(String categoryName, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          color: isSelected ? color : AppColors.darkGray,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegends(Map<String, dynamic> data) {
    final categories = data['categories'] as List<dynamic>;
    final amounts = data['amounts'] as List<dynamic>;

    // 색상 리스트 생성
    final colors = [
      AppColors.primary, // 기본 앱 컬러
      const Color(0xfff8b250), // 주황색
      const Color(0xff845bef), // 보라색
      const Color(0xff13d38e), // 초록색
      const Color(0xfffd8c73), // 연한 빨강
    ];

    // 카테고리에 맞는 아이콘 매핑
    final Map<String, IconData> categoryIcons = {
      '양식': Icons.restaurant,
      '일식': Icons.ramen_dining,
      '한식': Icons.rice_bowl,
      '디저트': Icons.cake,
      '분식': Icons.lunch_dining,
      '중식': Icons.restaurant_menu,
      '패스트푸드': Icons.fastfood,
      '카페': Icons.coffee,
      '주류': Icons.local_bar,
      '편의점': Icons.local_convenience_store,
      '쇼핑': Icons.shopping_bag,
      '교통': Icons.directions_bus,
      '문화': Icons.movie,
      '건강': Icons.fitness_center,
      '의료': Icons.medical_services,
      '여행': Icons.flight,
      '주거': Icons.home,
      '교육': Icons.school,
      '취미': Icons.sports_esports,
      '금융': Icons.account_balance,
      '기타': Icons.more_horiz,
    };

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리 상세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(categories.length, (index) {
                final isSelected = index == touchedIndex;
                final categoryName = categories[index].toString();
                final iconData = categoryIcons[categoryName] ?? Icons.category;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length].withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            color: colors[index % colors.length],
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(amounts[index])}원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected
                                  ? colors[index % colors.length]
                                  : AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
