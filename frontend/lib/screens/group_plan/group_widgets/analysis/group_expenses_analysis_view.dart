// lib/screens/group_plan/group_widgets/analysis/group_expenses_analysis_view.dart
import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';
import 'package:frontend/models/analysis/category_analysis_model.dart';
import 'package:frontend/services/api/group_analysis_api.dart';
import 'package:frontend/widgets/clover_loading_spinner.dart';

import 'charts/basic_comparison_tab.dart';
import 'charts/personnel_comparison_tab.dart';
import 'charts/time_comparison_tab.dart';
import 'charts/day_of_week_comparison_tab.dart';
import 'charts/category_analysis_tab.dart';

class GroupExpensesAnalysisView extends StatefulWidget {
  final int groupId;

  const GroupExpensesAnalysisView({Key? key, required this.groupId})
      : super(key: key);

  @override
  State<GroupExpensesAnalysisView> createState() =>
      _GroupExpensesAnalysisViewState();
}

class _GroupExpensesAnalysisViewState extends State<GroupExpensesAnalysisView>
    with SingleTickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;

  // 분석 데이터 상태
  GroupAnalysisResult? _analysisResult;
  CategoryAnalysisResult? _categoryResult;
  bool _isLoading = true;
  String? _error;

  // 날짜 필터
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAnalysisData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 그룹 분석 데이터 로드
      final analysisResult = await GroupAnalysisApi.getGroupAnalysis(
        widget.groupId,
      );

      // 카테고리 분석 데이터 로드
      final categoryResult = await GroupAnalysisApi.getGroupCategoryAnalysis(
        widget.groupId,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _analysisResult = analysisResult;
          _categoryResult = categoryResult;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "분석 데이터를 불러오는데 실패했습니다: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 필터 (나중에 추가 가능)
          // _buildDateFilter(),

          // 탭 바
          _buildTabBar(),

          // 탭 컨텐츠
          Expanded(
            child: _isLoading
                ? const Center(child: CloverLoadingSpinner())
                : _error != null
                    ? _buildErrorView()
                    : _buildTabContent(),
          ),
        ],
      ),
    );
  }

  // 에러 표시 위젯
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? '알 수 없는 오류가 발생했습니다',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAnalysisData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // 탭 바 위젯
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.darkGray,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: '기본 비교'),
        Tab(text: '인원별 소비'),
        Tab(text: '시간대별 소비'),
        Tab(text: '요일별 소비'),
        Tab(text: '카테고리별 소비'),
      ],
    );
  }

  // 탭 컨텐츠 위젯
  Widget _buildTabContent() {
    // 분석 결과가 없는 경우 처리
    if (_analysisResult == null && _categoryResult == null) {
      return _buildNoDataView();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // 1. 기본 비교 탭
        BasicComparisonTab(analysisResult: _analysisResult),
        
        // 2. 인원별 소비 패턴 탭
        PersonnelComparisonTab(analysisResult: _analysisResult),
        
        // 3. 시간대별 소비 패턴 탭
        TimeComparisonTab(analysisResult: _analysisResult),
        
        // 4. 요일별 소비 패턴 탭
        DayOfWeekComparisonTab(analysisResult: _analysisResult),
        
        // 5. 카테고리별 소비 패턴 탭
        CategoryAnalysisTab(categoryResult: _categoryResult),
      ],
    );
  }

  // 데이터 없음 표시 위젯
  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png', // 이미지가 없으면 아이콘으로 대체
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.analytics_outlined,
                size: 80,
                color: AppColors.lightGray,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 분석할 데이터가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '여행 계획을 만들고 지출 정보를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 여행 계획 생성으로 이동 또는 적절한 작업 수행
            },
            icon: const Icon(Icons.add),
            label: const Text('여행 계획 생성'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}