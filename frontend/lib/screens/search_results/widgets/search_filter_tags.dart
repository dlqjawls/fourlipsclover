// lib/screens/search_results/widgets/search_filter_tags.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart'; // 테마 색상 적용
import '../../../providers/search_provider.dart'; // SearchProvider 추가
import '../../../models/restaurant_model.dart'; // RestaurantResponse 모델 추가

class SearchFilterTags extends StatefulWidget {
  final String? selectedFilter;
  final Function(String) onFilterChanged;
  final String locationName; // 지역명 추가

  const SearchFilterTags({
    Key? key,
    this.selectedFilter,
    required this.onFilterChanged,
    required this.locationName,
  }) : super(key: key);

  @override
  State<SearchFilterTags> createState() => _SearchFilterTagsState();
}

class _SearchFilterTagsState extends State<SearchFilterTags> {
  // 인기 해시태그 목록을 저장할 변수
  List<String> _popularTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 인기 태그 추출
    _extractPopularTags();
  }

  @override
  void didUpdateWidget(SearchFilterTags oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 검색 쿼리가 변경된 경우 태그 다시 추출
    if (widget.locationName != oldWidget.locationName) {
      _extractPopularTags();
    }
  }

  // 검색 결과에서 인기 태그 추출 메서드
  void _extractPopularTags() {
    setState(() {
      _isLoading = true;
    });

    // 약간의 지연을 줘서 SearchProvider의 결과가 업데이트될 시간 제공
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      final searchResults = searchProvider.searchResults;

      // 태그 빈도수를 계산하기 위한 맵
      Map<String, int> tagFrequencyMap = {};

      // 각 레스토랑의 태그 처리
      for (RestaurantResponse restaurant in searchResults) {
        if (restaurant.tags != null && restaurant.tags!.isNotEmpty) {
          for (Map<String, dynamic> tagData in restaurant.tags!) {
            final tagName = tagData['tagName'] as String?;
            if (tagName != null && tagName.isNotEmpty) {
              // 태그 빈도수 증가
              tagFrequencyMap[tagName] = (tagFrequencyMap[tagName] ?? 0) + 1;
            }
          }
        }
      }

      // 빈도수 기준 정렬 (내림차순)
      List<MapEntry<String, int>> sortedEntries =
          tagFrequencyMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      // 상위 15개 태그만 선택 (또는 더 적은 수의 태그가 있다면 전부)
      List<String> popularTags =
          sortedEntries.take(15).map((entry) => entry.key).toList();

      // 태그가 없으면 기본 태그 사용
      if (popularTags.isEmpty) {
        popularTags = [
          "맛집",
          "분위기좋은",
          "가성비",
          "데이트",
          "깔끔한",
          "친절한",
          "넓은",
          "특별한",
          "매운맛",
          "건강한",
          "신선한",
        ];
      }

      setState(() {
        _popularTags = popularTags;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 멘트 추가 - 상단 여백 증가
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), // 상하 간격 증가
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "👨🏻‍🍳 ", style: TextStyle(fontSize: 14)),
                TextSpan(
                  text: "${widget.locationName}",
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary, // 밑줄 색상 설정
                    decorationThickness: 2, // 밑줄 두께 설정
                    decorationStyle: TextDecorationStyle.solid, // 밑줄 스타일 설정
                  ),
                ),
                TextSpan(
                  text: " 에서 많이 검색된 해시태그",
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 로딩 중인 경우 스켈레톤 표시
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                10,
                (index) => Container(
                  width: 60 + (index % 3) * 20, // 다양한 너비의 스켈레톤
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.verylightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          )
        else
          // 필터 태그 - Wrap 위젯으로 변경
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // 하단 여백 증가
            child: Wrap(
              spacing: 8, // 태그 사이 가로 간격
              runSpacing: 8, // 태그 사이 세로 간격
              children:
                  _popularTags.map((tagName) {
                    final isSelected = tagName == widget.selectedFilter;

                    return GestureDetector(
                      onTap: () => widget.onFilterChanged(tagName),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.verylightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tagName, // 해시태그 앞에 # 붙이지 않음 (필요시 "#$tagName" 으로 변경)
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 13,
                            color:
                                isSelected ? Colors.white : AppColors.darkGray,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        // 추가 간격
        SizedBox(height: 12),
      ],
    );
  }
}
