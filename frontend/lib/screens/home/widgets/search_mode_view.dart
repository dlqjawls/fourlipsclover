// lib/screens/home/widgets/search_mode_view.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../../models/search_history.dart';
import './search_history_item.dart';

class SearchModeView extends StatelessWidget {
  final TextEditingController controller;
  final List<SearchHistory> searchHistory;
  final Function(String) onSearch;
  final VoidCallback onBack;
  final VoidCallback onClearHistory;
  final Function(int) onRemoveHistoryItem;

  const SearchModeView({
    Key? key,
    required this.controller,
    required this.searchHistory,
    required this.onSearch,
    required this.onBack,
    required this.onClearHistory,
    required this.onRemoveHistoryItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 바
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "식당의 이름을 입력해보세요",
                    hintStyle: TextStyle(color: AppColors.mediumGray),
                    filled: true,
                    fillColor: AppColors.verylightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: AppColors.primary),
                      onPressed: () => onSearch(controller.text),
                    ),
                  ),
                  onSubmitted: onSearch,
                ),
              ),
            ],
          ),
        ),

        // 최근 검색어 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "최근 검색어",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: onClearHistory,
                child: Text("모두 지우기", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),

        // 검색 기록 목록
        Expanded(
          child:
              searchHistory.isEmpty
                  ? Center(
                    child: Text(
                      "검색 기록이 없습니다",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: searchHistory.length,
                    itemBuilder: (context, index) {
                      return SearchHistoryItem(
                        searchHistory: searchHistory[index],
                        onTap: () {
                          controller.text = searchHistory[index].query;
                          onSearch(searchHistory[index].query);
                        },
                        onRemove: () => onRemoveHistoryItem(index),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}