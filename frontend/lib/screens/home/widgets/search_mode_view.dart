// lib/screens/home/widgets/search_mode_view.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/search_history.dart';
import './search_history_item.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보를 얻기 위한 패키지

class SearchModeView extends StatefulWidget {
  final TextEditingController controller;
  final List<SearchHistory> searchHistory;
  final Function(String) onSearch;
  final Function(String, List<String>)? onSearchWithTags; // 태그 검색 콜백 추가
  final Function(double, double)? onLocationSearch; // 위치 기반 검색 콜백 추가
  final VoidCallback onBack;
  final VoidCallback onClearHistory;
  final Function(int) onRemoveHistoryItem;
  final List<String> selectedTags; // 선택된 태그 목록

  const SearchModeView({
    Key? key,
    required this.controller,
    required this.searchHistory,
    required this.onSearch,
    this.onSearchWithTags,
    this.onLocationSearch,
    required this.onBack,
    required this.onClearHistory,
    required this.onRemoveHistoryItem,
    this.selectedTags = const [],
  }) : super(key: key);

  @override
  _SearchModeViewState createState() => _SearchModeViewState();
}

class _SearchModeViewState extends State<SearchModeView> {
  bool _hasText = false;
  late List<String> _localSelectedTags;

  @override
  void initState() {
    super.initState();
    // 텍스트 변경 리스너 추가
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;

    // 선택된 태그 목록 복사
    _localSelectedTags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    // 리스너 제거
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // 텍스트 변경 감지
  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  // 텍스트 지우기
  void _clearText() {
    widget.controller.clear();
  }

  // 태그 제거
  void _removeTag(String tag) {
    setState(() {
      _localSelectedTags.remove(tag);
    });
  }

  // 위치 기반 검색 실행
  Future<void> _performLocationSearch() async {
    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 권한이 거부된 경우
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('위치 접근 권한이 필요합니다')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 영구적으로 거부된 경우
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('설정에서 위치 접근 권한을 활성화해주세요')));
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 디버깅용 - 위치 정보 로그 출력
      print('현재 위치 - 위도: ${position.latitude}, 경도: ${position.longitude}');

      // 위치 기반 검색 콜백 실행
      if (widget.onLocationSearch != null) {
        widget.onLocationSearch!(position.latitude, position.longitude);
      } else {
        // 태그 검색 콜백이 있다면 태그와 함께 검색
        if (widget.onSearchWithTags != null && _localSelectedTags.isNotEmpty) {
          widget.onSearchWithTags!("내 주변", _localSelectedTags);
        } else {
          // 기본 검색어로 "내 주변" 사용
          widget.onSearch("내 주변");
        }
      }
    } catch (e) {
      // 오류 발생 시
      print('위치 가져오기 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('위치를 가져오는데 실패했습니다: $e')));

      // 태그 검색 콜백이 있다면 태그와 함께 검색
      if (widget.onSearchWithTags != null && _localSelectedTags.isNotEmpty) {
        widget.onSearchWithTags!("내 주변", _localSelectedTags);
      } else {
        // 위치를 가져오지 못했을 때 기본 검색어 사용
        widget.onSearch("내 주변");
      }
    }
  }

  // 검색 수행
  void _performSearch() {
    if (widget.controller.text.isEmpty) {
      // 텍스트가 없으면 위치 기반 검색 실행
      _performLocationSearch();
    } else {
      // 태그 검색 콜백이 있다면 태그와 함께 검색
      if (widget.onSearchWithTags != null && _localSelectedTags.isNotEmpty) {
        widget.onSearchWithTags!(widget.controller.text, _localSelectedTags);
      } else {
        // 텍스트만 있으면 일반 검색 실행
        widget.onSearch(widget.controller.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 바 - CustomSearchBar와 동일한 스타일로 변경
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: AppColors.verylightGray,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 선택된 태그들 표시
                        if (_localSelectedTags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 60,
                              top: 8,
                              bottom: 4,
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _localSelectedTags
                                      .map((tag) => _buildTagChip(tag))
                                      .toList(),
                            ),
                          ),

                        TextField(
                          controller: widget.controller,
                          autofocus: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "식당의 이름을 입력해보세요",
                            hintStyle: TextStyle(color: AppColors.mediumGray),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: _localSelectedTags.isNotEmpty ? 8 : 0,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: _hasText ? _clearText : _performSearch,
                                child: Icon(
                                  _hasText ? Icons.close : Icons.search,
                                  color:
                                      _hasText
                                          ? AppColors.mediumGray
                                          : AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ],
                    ),
                  ),
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
              const Text(
                "최근 검색어",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: widget.onClearHistory,
                child: const Text(
                  "모두 지우기",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),

        // 검색 기록 목록
        Expanded(
          child:
              widget.searchHistory.isEmpty
                  ? const Center(
                    child: Text(
                      "검색 기록이 없습니다",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: widget.searchHistory.length,
                    itemBuilder: (context, index) {
                      return SearchHistoryItem(
                        searchHistory: widget.searchHistory[index],
                        onTap: () {
                          widget.controller.text =
                              widget.searchHistory[index].query;
                          widget.onSearch(widget.searchHistory[index].query);
                        },
                        onRemove: () => widget.onRemoveHistoryItem(index),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // 태그 칩 위젯 빌드
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mediumGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(Icons.close, size: 12, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }
}
