// lib/screens/home/widgets/tagged_search_bar.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';

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

class TaggedSearchBarState extends State<TaggedSearchBar> {
  int _currentHintIndex = 0;
  late Timer _timer;
  bool _showHint = true;

  // 텍스트 컨트롤러 추가
  final TextEditingController _textController = TextEditingController();

  // 로컬 선택 태그 목록
  late List<String> _localSelectedTags;

  final List<String> _hintTexts = [
    "어떤 음식을 찾으시나요?",
    "어디에 있는 맛집을 찾아볼까요?",
    "식당의 이름을 입력해보세요",
  ];

  @override
  void initState() {
    super.initState();

    // 부모 위젯에서 전달받은 태그 목록 복사
    _localSelectedTags = List.from(widget.selectedTags);

    // 텍스트 컨트롤러 리스너 추가
    _textController.addListener(_onTextChanged);

    // 힌트 텍스트 순환 타이머
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // 텍스트 필드에 입력값이 있거나 태그가 있으면 힌트를 표시하지 않음
      if (_textController.text.isNotEmpty || _localSelectedTags.isNotEmpty)
        return;

      setState(() {
        _showHint = false;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted &&
            _textController.text.isEmpty &&
            _localSelectedTags.isEmpty) {
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
    setState(() {
      // 텍스트가 입력되면 힌트 숨기기
      if (_textController.text.isNotEmpty || _localSelectedTags.isNotEmpty) {
        _showHint = false;
      } else if (_textController.text.isEmpty && _localSelectedTags.isEmpty) {
        _showHint = true;
      }
    });
  }

  // 태그 제거
  void _removeTag(String tag) {
    setState(() {
      _localSelectedTags.remove(tag);
      _onTextChanged(); // 힌트 상태 업데이트
    });
  }

  // 태그 추가 (HashtagSelector에서 호출할 메서드)
  void addTag(String tag) {
    if (!_localSelectedTags.contains(tag)) {
      setState(() {
        _localSelectedTags.add(tag);
        _onTextChanged(); // 힌트 상태 업데이트
      });
    }
  }

  // 검색 실행 함수
  void _performSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_textController.text, _localSelectedTags);
    } else {
      // 기본 검색 동작 (콘솔에 출력)
      print('검색어: ${_textController.text}, 태그: $_localSelectedTags');
      // TODO: 실제 검색 로직 구현
    }
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
                  text: '에서\n랭킹이 높은 곳은 어디일까요?',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 22, height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque, // 중요! 이 옵션을 추가
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 선택된 태그들을 보여주는 영역
                    if (_localSelectedTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 60.0,
                          top: 10.0,
                          bottom: 10.0,
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

                    AbsorbPointer(
                      // 추가: TextField의 탭 이벤트 차단
                      absorbing: true, // TextField의 터치 이벤트를 흡수
                      child: TextField(
                        controller: _textController,
                        enabled: false, // 비활성화하여 포커스 받지 않도록 설정
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "",
                          contentPadding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: _localSelectedTags.isNotEmpty ? 20 : 0,
                            bottom: _localSelectedTags.isNotEmpty ? 10 : 0,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.search,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    if (_textController.text.isEmpty &&
                        _localSelectedTags.isEmpty)
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
