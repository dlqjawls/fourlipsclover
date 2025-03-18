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

    // TODO: 여기서 검색 쿼리와 필터를 기반으로 데이터 로드
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
    // TODO: 필터 변경에 따른 데이터 다시 로드
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
          backgroundColor: Colors.white,
          elevation: 0.5,
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
      body: Column(
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkGray,
                        ),
                      ),
                      TextSpan(
                        text: " 맛집 ",
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkGray,
                        ),
                      ),
                      TextSpan(
                        text: "(91",
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: AppColors.darkGray),
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

          // 검색 결과 리스트
          Expanded(
            child: SearchResultList(
              query: _currentQuery,
              filter: _selectedFilter,
            ),
          ),
        ],
      ),
    );
  }
}
