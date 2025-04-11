// search_filter_tags.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart'; // 테마 색상 적용

class SearchFilterTags extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 필터 목록
    final List<String> filters = [
      "스테이크",
      "횟집",
      "파스타",
      "초밥",
      "고깃집",
      "조개",
      "술집",
      "카페",
      "분식",
      "치킨",
      "한식",
      "중식",
      "일식",
      "양식",
      "세계음식",
    ];

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
                  text: "$locationName",
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

        // 필터 태그 - Wrap 위젯으로 변경
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // 하단 여백 증가
          child: Wrap(
            spacing: 8, // 태그 사이 가로 간격
            runSpacing: 8, // 태그 사이 세로 간격
            children:
                filters.map((filter) {
                  final isSelected = filter == selectedFilter;

                  return GestureDetector(
                    onTap: () => onFilterChanged(filter),
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
                        filter,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppColors.darkGray,
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
