// lib/screens/home/widgets/tagged_search_bar.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/search_provider.dart';

class TaggedSearchBar extends StatefulWidget {
  // 검색 콜백 함수 (태그 포함)
  final Function(String, List<String>)? onSearch;
  // 탭 콜백 함수 추가
  final VoidCallback? onTap;
  // 선택된 태그 목록
  final List<String> selectedTags;

  const TaggedSearchBar({
    Key? key,
    this.onSearch,
    this.onTap,
    this.selectedTags = const [],
  }) : super(key: key);

  @override
  TaggedSearchBarState createState() => TaggedSearchBarState();
}

class TaggedSearchBarState extends State<TaggedSearchBar>
    with AutomaticKeepAliveClientMixin {
  int _currentHintIndex = 0;
  late Timer _timer;
  bool _showHint = true;

  // 상태 유지를 위한 오버라이드
  @override
  bool get wantKeepAlive => true;

  // 텍스트 컨트롤러 추가
  final TextEditingController _textController = TextEditingController();

  final List<String> _hintTexts = [
    "어떤 음식을 찾으시나요?",
    "어디에 있는 맛집을 찾아볼까요?",
    "식당의 이름을 입력해보세요",
  ];

  @override
  void initState() {
    super.initState();

    // 텍스트 컨트롤러 리스너 추가
    _textController.addListener(_onTextChanged);

    // 힌트 텍스트 순환 타이머
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      // 태그 선택 여부와 관계없이 힌트 텍스트 표시
      // 텍스트 필드에 입력값이 있으면 힌트를 표시하지 않음
      if (_textController.text.isNotEmpty) {
        return;
      }

      setState(() {
        _showHint = false;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _textController.text.isEmpty) {
          setState(() {
            _currentHintIndex = (_currentHintIndex + 1) % _hintTexts.length;
            _showHint = true;
          });
        }
      });
    });
  }

  // 텍스트 변경 감지
  void _onTextChanged() {
    if (!mounted) return;

    setState(() {
      // 텍스트가 입력되면 힌트 숨기기, 그렇지 않으면 힌트 표시
      // 태그 선택 여부와 무관하게 처리
      if (_textController.text.isNotEmpty) {
        _showHint = false;
      } else {
        _showHint = true;
      }
    });
  }

  // 태그 제거
  void _removeTag(String tag) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.removeTag(tag);
  }

  // 태그 추가 (HashtagSelector에서 호출할 메서드)
  void addTag(String tag) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.addTag(tag);
  }

  // 검색 실행 함수
  void _performSearch() {
  final searchProvider = Provider.of<SearchProvider>(context, listen: false);
  final selectedTags = searchProvider.selectedTags;
  final selectedTagIds = searchProvider.selectedTagIds; // 태그 ID 가져오기
  
  if (widget.onSearch != null) {
    // 태그 이름과 함께 태그 ID도 전달 (UI 코드 업데이트 필요)
    widget.onSearch!(_textController.text, selectedTags);
  } else {
    // 기본 검색 동작
    print('검색어: ${_textController.text}, 태그: $selectedTags, 태그 ID: $selectedTagIds');
  }
}

  // 모든 태그 제거 함수
  void _clearAllTags() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.clearTags();
  }

  @override
  void dispose() {
    _timer.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항

    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final selectedTags = searchProvider.selectedTags;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '내 주변',
                      style:
                          Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 22, height: 1.3)
                              .emphasized,
                    ),
                    TextSpan(
                      text: '맛집을\n찾아볼까요?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 22,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // 검색바
              GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.opaque, // 중요! 이 옵션을 추가
                child: Container(
                  height: 60,
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
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 힌트 텍스트 표시 - 태그 선택 상태와 관계없이 표시 (수정됨)
                        if (_textController.text.isEmpty)
                          Positioned(
                            left: 20,
                            child: AnimatedOpacity(
                              opacity: _showHint ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Text(
                                _hintTexts[_currentHintIndex],
                                style: TextStyle(
                                  color: AppColors.mediumGray,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                        // 검색 아이콘
                        Positioned(
                          right: 16,
                          child: Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),

                        // TextField는 원래 코드와 비슷하게 유지
                        AbsorbPointer(
                          absorbing: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TextField(
                              controller: _textController,
                              enabled: false,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "",
                                contentPadding: EdgeInsets.only(
                                  left: 0,
                                  right: 20,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 선택된 태그들을 검색바 아래에 표시
              if (selectedTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              selectedTags
                                  .map((tag) => _buildTagChip(tag))
                                  .toList(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearAllTags,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            '모두 지우기',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 태그 칩 위젯 빌드 - 클릭 시 제거
  Widget _buildTagChip(String tag) {
    return GestureDetector(
      onTap: () => _removeTag(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.mediumGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
