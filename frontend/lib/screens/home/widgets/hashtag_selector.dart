import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../screens/search_results/search_results_screen.dart';

class HashtagSelector extends StatefulWidget {
  const HashtagSelector({Key? key}) : super(key: key);

  @override
  _HashtagSelectorState createState() => _HashtagSelectorState();
}

class _HashtagSelectorState extends State<HashtagSelector> {
  String? selectedHashtag;
  bool isExpanded = false;

  // 해시태그 목록 (나중에 API에서 불러올 데이터)
  // TODO: API 연동 - 해시태그 목록을 서버에서 가져오는 기능 구현
  final List<String> hashtags = [
    '#아재입맛',
    '#24시영업',
    '#아기입맛',
    '#가성비맛집',
    '#반주맛집',
    '#한식',
    '#양식',
    '#일식',
    '#중식',
    '#횟집',
    '#매운맛',
    '#건강식',
    '#디저트',
    '#카페',
    '#노포맛집',
    '#인스타감성',
    '#혼밥',
    '#데이트코스',
  ];

  // 초기에 보여줄 해시태그 개수
  final int initialTagCount = 3;

 void _handleTagSelection(String hashtag) {
  setState(() {
    selectedHashtag = hashtag;
  });

  // 검색 결과 페이지로 이동
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SearchResultsScreen(
        searchQuery: "맛집",  // 기본 검색어
        selectedTag: hashtag,  // 선택된 해시태그
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 해시태그 Wrap으로 자연스럽게 배치
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 모든 해시태그 또는 초기 몇 개만 표시
              ...isExpanded
                  ? hashtags.map((tag) => _buildHashtagItem(tag))
                  : hashtags
                      .take(initialTagCount)
                      .map((tag) => _buildHashtagItem(tag)),

              // 확장/축소 버튼
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGray),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagItem(String hashtag) {
    final isSelected = selectedHashtag == hashtag;

    return GestureDetector(
      onTap: () => _handleTagSelection(hashtag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGray,
          ),
        ),
        child: Text(
          hashtag,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.darkGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
