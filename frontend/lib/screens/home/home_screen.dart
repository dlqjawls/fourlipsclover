// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/logo_section.dart';
import 'widgets/search_bar.dart';
import 'widgets/hashtag_selector.dart';
import 'widgets/local_favorites.dart';
import 'widgets/category_recommendations.dart';
import 'widgets/search_mode_view.dart';
import '../../providers/search_provider.dart';
import '../search_results/search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Provider 초기화 - 앱 시작 시 검색 기록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      searchProvider.initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed && searchProvider.isSearchMode) {
      searchProvider.toggleSearchMode(false, null);
    }
  }

  void _handleSearch(String query) {
    print('검색어: $query');

    // 검색 기록에 추가
    if (query.trim().isNotEmpty) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      searchProvider.addSearchHistory(query);

      // 검색 결과 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(searchQuery: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Provider 사용
    final searchProvider = Provider.of<SearchProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (searchProvider.isSearchMode) {
          searchProvider.toggleSearchMode(false, null);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child:
              searchProvider.isSearchMode
                  ? SearchModeView(
                    controller: _searchController,
                    searchHistory: searchProvider.searchHistory,
                    onBack: () => searchProvider.toggleSearchMode(false, null),
                    onSearch: _handleSearch,
                    onClearHistory: () => searchProvider.clearSearchHistory(),
                    onRemoveHistoryItem:
                        (index) =>
                            searchProvider.removeSearchHistoryItem(index),
                  )
                  : _buildNormalModeUI(screenHeight, searchProvider),
        ),
      ),
    );
  }

  Widget _buildNormalModeUI(
    double screenHeight,
    SearchProvider searchProvider,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 섹션
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: LogoSection(),
          ),

          const SizedBox(height: 50),

          // 검색창 - 탭하면 검색 모드로 전환
          CustomSearchBar(
            onSearch: (query) {
              _searchController.text = query;
              _handleSearch(query);
            },
            onTap: () {
              final searchProvider = Provider.of<SearchProvider>(
                context,
                listen: false,
              );
              searchProvider.toggleSearchMode(true, _searchController);
            },
          ),

          // 해시태그 선택기
          const HashtagSelector(),

          SizedBox(height: screenHeight * 0.05),

          // 지역 인기 장소
          const LocalFavorites(),

          const SizedBox(height: 24),

          // 카테고리 추천
          const CategoryRecommendations(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
