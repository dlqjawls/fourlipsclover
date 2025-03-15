// search_filter_tags.dart
import 'package:flutter/material.dart';

class SearchFilterTags extends StatelessWidget {
  final String? selectedFilter;
  final Function(String) onFilterChanged;

  const SearchFilterTags({
    Key? key,
    this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 필터 목록
    final List<String> filters = [
      "스테이크", "횟집", "파스타", "초밥", "고깃집", "조개", "술집"
    ];

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(filter),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                onFilterChanged(filter);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}