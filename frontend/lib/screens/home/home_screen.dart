// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/logo_section.dart';
import 'widgets/tagged_search_bar.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  // TaggedSearchBar에 접근하기 위한 GlobalKey 추가
  final GlobalKey<TaggedSearchBarState> _taggedSearchBarKey = GlobalKey<TaggedSearchBarState>();

  // 상태 유지를 위한 오버라이드
  @override
  bool get wantKeepAlive => true;

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

  // 기존 검색 핸들러
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

  // 태그 포함 검색 핸들러 추가
void _handleSearchWithTags(String query, List<String> tags) {
  print('HomeScreen: 검색 직전 태그 목록 - $tags');
  
  // 검색 기록에 추가
  final searchProvider = Provider.of<SearchProvider>(context, listen: false);
  if (query.trim().isNotEmpty) {
    searchProvider.addSearchHistory(query);
  }
  
  print('HomeScreen: Provider에 저장된 태그 목록 - ${searchProvider.selectedTags}');
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(
        searchQuery: query.trim().isNotEmpty ? query : "맛집",
        // IMPORTANT: Use the provider's tags directly
        selectedTags: searchProvider.selectedTags,
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
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
          child: searchProvider.isSearchMode
              ? SearchModeView(
                  controller: _searchController,
                  searchHistory: searchProvider.searchHistory,
                  selectedTags: searchProvider.selectedTags,
                  onBack: () => searchProvider.toggleSearchMode(false, null),
                  onSearch: _handleSearch,
                  onSearchWithTags: _handleSearchWithTags,
                  onClearHistory: () => searchProvider.clearSearchHistory(),
                  onRemoveHistoryItem: (index) =>
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
      key: const PageStorageKey<String>('homeScrollPosition'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 섹션
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: LogoSection(),
          ),

          const SizedBox(height: 50),

          // TaggedSearchBar
          TaggedSearchBar(
            key: _taggedSearchBarKey,
            selectedTags: searchProvider.selectedTags,
            onSearch: (query, tags) {
              _handleSearchWithTags(query, tags);
            },
            onTap: () {
              searchProvider.toggleSearchMode(true, _searchController);
            },
          ),

          // 해시태그 선택기
          HashtagSelector(
            // 태그 선택 콜백은 SearchProvider에서 직접 처리
            onTagSelected: (tag) {
              // 이미 Provider에서 태그를 관리하므로 추가 작업 필요 없음
            },
          ),

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