import 'package:flutter/material.dart';
import 'dart:async';
import '../../../config/theme.dart';

class CustomSearchBar extends StatefulWidget {
  // 검색 콜백 함수 추가
  final Function(String)? onSearch;

  const CustomSearchBar({Key? key, this.onSearch}) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  int _currentHintIndex = 0;
  late Timer _timer;
  bool _showHint = true;

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
      // 텍스트 필드에 입력값이 있으면 힌트를 표시하지 않음
      if (_textController.text.isNotEmpty) return;

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
    setState(() {
      // 텍스트가 입력되면 힌트 숨기기
      if (_textController.text.isNotEmpty) {
        _showHint = false;
      } else if (_textController.text.isEmpty) {
        _showHint = true;
      }
    });
  }

  // 검색 실행 함수
  void _performSearch() {
    if (_textController.text.isEmpty) return;

    if (widget.onSearch != null) {
      widget.onSearch!(_textController.text);
    } else {
      // 기본 검색 동작 (콘솔에 출력)
      print('검색어: ${_textController.text}');
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
                  text: '내 주변에서\n',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                    height: 1.3,
                  ),
                ),
                TextSpan(
                  text: '랭킹이 높은 곳은 어디일까요?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                    color: AppColors.darkGray,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          Container(
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
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _textController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _performSearch,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    // 키보드에서 검색/완료 버튼을 눌렀을 때 검색 실행
                    onSubmitted: (value) => _performSearch(),
                  ),

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
