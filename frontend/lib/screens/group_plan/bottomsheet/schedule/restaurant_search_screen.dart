// lib/screens/group_plan/bottomsheet/restaurant_search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../models/restaurant_model.dart';
import '../../../../models/search_history.dart';
import '../../../../providers/search_provider.dart';
import '../../../../widgets/clover_loading_spinner.dart';
import '../../../home/widgets/search_history_item.dart'; // SearchHistoryItem 위젯 추가

class RestaurantSearchScreen extends StatefulWidget {
  const RestaurantSearchScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();

    // 화면 진입 시 검색 결과 초기화 및 히스토리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      // 이전 검색 결과 초기화
      searchProvider.clearSearchResults();
      // 검색 히스토리 로드
      searchProvider.loadSearchHistory();
    });

    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 검색 실행 메서드
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      searchProvider.addSearchHistory(query);
      searchProvider.fetchSearchResults(query);
      FocusScope.of(context).unfocus();
    }
  }

  // 검색 기록 클릭 시 검색 실행
  void _searchHistoryItem(String query) {
    _searchController.text = query;
    _performSearch();
  }

  // 레스토랑 선택 처리
  void _selectRestaurant(RestaurantResponse restaurant) {
    // 선택된 레스토랑 정보를 이전 화면으로 반환
    Navigator.pop(context, restaurant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: '레스토랑을 검색하세요',
            hintStyle: TextStyle(color: AppColors.mediumGray, fontSize: 16),
            border: InputBorder.none,
            suffixIcon:
                _showClearButton
                    ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.mediumGray),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                    : IconButton(
                      icon: Icon(Icons.search, color: AppColors.primary),
                      onPressed: _performSearch,
                    ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          // 로딩 상태 처리
          if (searchProvider.isLoading) {
            return const Center(child: CloverLoadingSpinner());
          }

          // 에러 상태 처리
          if (searchProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '검색 중 오류가 발생했습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 검색 결과가 있는 경우
          if (searchProvider.searchResults.isNotEmpty) {
            return ListView.builder(
              itemCount: searchProvider.searchResults.length,
              itemBuilder: (context, index) {
                final restaurant = searchProvider.searchResults[index];
                return _buildRestaurantItem(restaurant);
              },
            );
          }

          // 검색 결과가 없지만 검색어가 입력된 경우
          if (_searchController.text.isNotEmpty && !searchProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.mediumGray),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                  ),
                ],
              ),
            );
          }

          // 기본 상태 - 검색 히스토리 표시
          return _buildSearchHistory(searchProvider);
        },
      ),
    );
  }

  // 레스토랑 아이템 위젯
  Widget _buildRestaurantItem(RestaurantResponse restaurant) {
    return InkWell(
      onTap: () => _selectRestaurant(restaurant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.verylightGray)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 식당 이름
            Text(
              restaurant.placeName ?? '이름 없음',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // 카테고리
            if (restaurant.category != null)
              Text(
                restaurant.category!,
                style: TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            const SizedBox(height: 4),

            // 주소
            Text(
              restaurant.roadAddressName ?? restaurant.addressName ?? '주소 없음',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 히스토리 위젯
  Widget _buildSearchHistory(SearchProvider searchProvider) {
    final searchHistory = searchProvider.searchHistory;

    if (searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: AppColors.lightGray),
            const SizedBox(height: 16),
            Text(
              '검색 기록이 없습니다',
              style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              TextButton(
                onPressed: () {
                  searchProvider.clearSearchHistory();
                },
                child: Text(
                  '전체 삭제',
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              final item = searchHistory[index];
              return SearchHistoryItem(
                searchHistory: item,
                onTap: () => _searchHistoryItem(item.query),
                onRemove: () => searchProvider.removeSearchHistoryItem(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
