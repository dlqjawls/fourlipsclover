// search_results_screen.dart
import 'package:flutter/material.dart';
import 'widgets/map_preview.dart';
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

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _selectedFilter = widget.selectedTag;
    
    // TODO: 여기서 검색 쿼리와 필터를 기반으로 데이터 로드
  }

  // 필터 변경 처리
  void _handleFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // TODO: 필터 변경에 따른 데이터 다시 로드
  }

  // 지도 전체 화면으로 전환
  void _openFullMap() {
    // TODO: 지도 전체 화면으로 이동하는 로직
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentQuery,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 결과 카운트 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$_currentQuery 맛집 (91곳)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
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
          ),

          // 필터 태그
          SearchFilterTags(
            selectedFilter: _selectedFilter,
            onFilterChanged: _handleFilterChanged,
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