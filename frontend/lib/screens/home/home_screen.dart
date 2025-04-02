// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/logo_section.dart';
import 'widgets/tagged_search_bar.dart'; // CustomSearchBar 대신 TaggedSearchBar import
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
  // TaggedSearchBar에 접근하기 위한 GlobalKey 추가
  final GlobalKey<TaggedSearchBarState> _taggedSearchBarKey = GlobalKey<TaggedSearchBarState>();

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
    print('검색어: $query, 태그: $tags');

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
          builder: (context) => SearchResultsScreen(
            searchQuery: query,
            selectedTags: tags,
          ),
        ),
      );
    } else if (tags.isNotEmpty) {
      // 검색어 없이 태그만 있는 경우
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            searchQuery: "맛집",
            selectedTags: tags,
          ),
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
          child: searchProvider.isSearchMode
              ? SearchModeView(
                  controller: _searchController,
                  searchHistory: searchProvider.searchHistory,
                  selectedTags: searchProvider.selectedTags, // 태그 목록 전달
                  onBack: () => searchProvider.toggleSearchMode(false, null),
                  onSearch: _handleSearch,
                  onSearchWithTags: _handleSearchWithTags, // 태그 검색 콜백 추가
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 섹션
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: LogoSection(),
          ),

          const SizedBox(height: 50),

          // TaggedSearchBar로 교체
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
            // 태그 선택 콜백 추가
            onTagSelected: (tag) {
              // SearchProvider에 태그 추가
              searchProvider.addTag(tag);
              
              // TaggedSearchBar에 태그 추가
              if (_taggedSearchBarKey.currentState != null) {
                _taggedSearchBarKey.currentState!.addTag(tag);
              }
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