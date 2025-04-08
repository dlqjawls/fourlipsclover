// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/logo_section.dart';
import 'widgets/tagged_search_bar.dart';
import 'widgets/hashtag_selector.dart';
import 'widgets/local_favorites.dart';
import 'widgets/category_recommendations.dart';
import 'widgets/search_mode_view.dart';
import '../../providers/search_provider.dart';
import '../search_results/search_results_screen.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<TaggedSearchBarState> _taggedSearchBarKey =
      GlobalKey<TaggedSearchBarState>();

  // 새로 추가: 초대 토큰 변수
  String? _pendingInvitationToken;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      searchProvider.initialize();

      // 초대 토큰 확인
      _checkPendingInvitation();
    });
  }

  // 새로운 메서드: 초대 토큰 확인 및 알림
  Future<void> _checkPendingInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pendingInvitationToken');

    if (token != null && token.isNotEmpty) {
      setState(() {
        _pendingInvitationToken = token;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInvitationNoticeDialog(token);
      });
    }
  }

  // 초대 알림 다이얼로그
  void _showInvitationNoticeDialog(String token) {
    showDialog(
      context: context,
      barrierDismissible: false, // 외부 터치로 닫히지 않도록
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/clover.png', // 초대 일러스트레이션
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '새로운 그룹 초대',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 처리하지 않은 그룹 초대가 있습니다.\n지금 확인하고 새로운 모험을 시작해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.lightGray),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '나중에',
                          style: TextStyle(color: AppColors.darkGray),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                            '/group/invitation',
                            arguments: {'token': token},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '초대 확인하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
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
        builder:
            (context) => SearchResultsScreen(
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

    return PopScope(
      canPop: !searchProvider.isSearchMode,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Pop이 취소되면 검색 모드 비활성화
          searchProvider.toggleSearchMode(false, null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child:
              searchProvider.isSearchMode
                  ? SearchModeView(
                    controller: _searchController,
                    searchHistory: searchProvider.searchHistory,
                    selectedTags: searchProvider.selectedTags,
                    onBack: () => searchProvider.toggleSearchMode(false, null),
                    onSearch: _handleSearch,
                    onSearchWithTags: _handleSearchWithTags,
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

          SizedBox(height: screenHeight * 0.13),

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
