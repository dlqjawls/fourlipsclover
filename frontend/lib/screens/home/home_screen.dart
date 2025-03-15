import 'package:flutter/material.dart';
import 'widgets/logo_section.dart';
import 'widgets/search_bar.dart';
import 'widgets/hashtag_selector.dart';
import 'widgets/local_favorites.dart';
import 'widgets/category_recommendations.dart';
import 'widgets/search_mode_view.dart';
import '../../../models/search_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<SearchHistory> _searchHistory = [
    SearchHistory(query: "수완지구 양식", date: "03.14"),
    SearchHistory(query: "수완지구 술집", date: "03.10"),
    SearchHistory(query: "각화동", date: "03.08"),
    SearchHistory(query: "우츠", date: "03.07"),
    SearchHistory(query: "대전", date: "03.07"),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isSearchMode) {
      setState(() {
        _isSearchMode = false;
      });
    }
  }

  void _toggleSearchMode(bool value) {
    setState(() {
      _isSearchMode = value;
    });
  }

  void _handleSearch(String query) {
    print('검색어: $query');
    // 검색 기능 구현
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        if (_isSearchMode) {
          _toggleSearchMode(false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isSearchMode
              ? SearchModeView(
                  controller: _searchController,
                  searchHistory: _searchHistory,
                  onBack: () => _toggleSearchMode(false),
                  onSearch: _handleSearch,
                  onClearHistory: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  onRemoveHistoryItem: (index) {
                    setState(() {
                      _searchHistory.removeAt(index);
                    });
                  },
                )
              : _buildNormalModeUI(screenHeight),
        ),
      ),
    );
  }

  Widget _buildNormalModeUI(double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 섹션
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: LogoSection(),
          ),

          // 검색창 - 탭하면 검색 모드로 전환
          GestureDetector(
            onTap: () => _toggleSearchMode(true),
            child: CustomSearchBar(
              onSearch: (query) {
                _searchController.text = query;
                _handleSearch(query);
              },
            ),
          ),

          // 나머지 UI 요소들
          HashtagSelector(),
          SizedBox(height: screenHeight * 0.05),
          LocalFavorites(),
          const SizedBox(height: 24),
          CategoryRecommendations(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}