// search_results_screen.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart'; // 테마 색상 추가
import '../../widgets/map_preview.dart';
import 'widgets/search_filter_tags.dart';
import 'widgets/search_result_list.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final String? selectedTag; // 선택된 해시태그가 있다면 전달

  const SearchResultsScreen({
    Key? key,
    required this.searchQuery,
    this.selectedTag,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late String _currentQuery;
  String? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _selectedFilter = widget.selectedTag;
    _searchController.text = _currentQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 필터 변경 처리
  void _handleFilterChanged(String filter) {
    setState(() {
      if (_selectedFilter == filter) {
        // 이미 선택된 필터를 다시 탭하면 해제
        _selectedFilter = null;
      } else {
        _selectedFilter = filter;
      }
    });
  }

  // 지도 전체 화면으로 전환
  void _openFullMap() {
    // TODO: 지도 전체 화면으로 이동하는 로직
  }

  // 새 검색 화면으로 이동
  void _navigateToSearch() {
    // TODO: 실제 구현 시 Navigator.push를 사용하여 검색 화면으로 이동
    print('검색 화면으로 이동');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // AppBar 높이 증가
        child: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0.5,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.mediumGray.withOpacity(0.05), // 그림자 색상 고정
          automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
          titleSpacing: 0, // 타이틀 패딩 제거
          // AppBar를 Center로 감싸서 내용을 수직 가운데 정렬
          title: Center(
            child: Row(
              children: [
                // 뒤로가기 버튼
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(8),
                    iconSize: 28, // 아이콘 크기 증가
                  ),
                ),

                // 검색 바 - 높이 증가
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToSearch,
                    child: Container(
                      height: 50, // 검색 바 높이 증가
                      margin: EdgeInsets.only(right: 12, left: 4),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.verylightGray,
                        borderRadius: BorderRadius.circular(25), // 라운드 증가
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentQuery,
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 16, // 텍스트 크기 증가
                                color: AppColors.darkGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // X 버튼
                          GestureDetector(
                            onTap: _navigateToSearch,
                            child: Icon(
                              Icons.close,
                              color: AppColors.mediumGray,
                              size: 24, // X 아이콘 크기 증가
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        // 스크롤 이벤트 감지 (더 많은 항목 로드 위해)
        onNotification: (ScrollNotification scrollInfo) {
          // 스크롤이 끝에 가까워졌을 때 더 많은 데이터를 로드하도록 SearchResultList에 알림을 보낼 수 있음
          return false;
        },
        child: NestedScrollView(
          // 헤더가 스크롤될 때 스크롤 동작 설정
          physics: AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white, // 헤더 배경색 지정
                  child: Column(
                    children: [
                      // 검색 결과 카운트 표시
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$_currentQuery",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontSize: 18,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 맛집 (",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontSize: 18,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "91",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "곳)",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontSize: 18,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color: AppColors.darkGray,
                              ),
                              onPressed: () {
                                // 공유 기능 구현
                              },
                            ),
                          ],
                        ),
                      ),

                      // 지도 미리보기
                      MapPreview(
                        location: _currentQuery,
                        onTapViewMap: _openFullMap,
                        latitude: 35.1958,
                        longitude: 126.8149,
                      ),

                      // 필터 태그 - 지역명 전달
                      SearchFilterTags(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _handleFilterChanged,
                        locationName: _currentQuery, // 지역명 전달
                      ),

                      // 구분선 하나만 유지 (여기 하나만 두고 SearchResultList에서는 제거)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.verylightGray,
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          // 이 부분이 핵심! NestedScrollView의 body로 SearchResultList를 직접 사용
          body: SearchResultList(query: _currentQuery, filter: _selectedFilter),
        ),
      ),
    );
  }
}
