// lib/screens/group_plan/bottomsheet/notice_create_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/notice_item.dart'; // 기존 임시 모델 사용
import '../../../models/notice/notice_model.dart'; // 새 모델도 함께 참조
import '../../../providers/notice_provider.dart'; // 공지사항 Provider
import '../../../widgets/custom_switch.dart'; // 커스텀 스위치 임포트

class NoticeCreateBottomSheet extends StatefulWidget {
  final List<Color> availableColors;
  final Function(NoticeItem) onNoticeCreated;
  final int maxNoticeCount;
  final int planId; // 계획 ID 추가

  const NoticeCreateBottomSheet({
    Key? key,
    required this.availableColors,
    required this.onNoticeCreated,
    required this.planId, // 필수 파라미터로 변경
    this.maxNoticeCount = 6,
  }) : super(key: key);

  @override
  State<NoticeCreateBottomSheet> createState() =>
      _NoticeCreateBottomSheetState();
}

class _NoticeCreateBottomSheetState extends State<NoticeCreateBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  bool _isImportant = false;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.availableColors.first;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 글자 수 제한에 도달했는지 확인
  bool get _isMaxLengthReached => _contentController.text.length >= 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 키보드가 올라왔을 때 오버플로우 방지
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 핸들 바
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 타이틀
            const Text(
              '공지사항 추가',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 미리보기 및 색상 선택 영역을 함께 배치
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 미리보기 메모
                Container(
                  width: 160,
                  height: 160,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(1, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 메모 내용
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          20,
                          12,
                          12,
                        ), // 상단 여백 증가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 중요 표시
                            if (_isImportant)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '중요',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // 공지사항 내용
                            Expanded(
                              child: Text(
                                _contentController.text.isEmpty
                                    ? '공지사항 내용을 입력하세요'
                                    : _contentController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 자석 핀 (위쪽 중앙)
                      Positioned(
                        top: 3,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color:
                                  _isImportant
                                      ? Colors.red.shade300
                                      : Colors.blue.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 색상 선택 영역 (세로 배열)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 색상 타이틀
                        const Text(
                          '메모 색상',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 색상 선택 그리드
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              widget.availableColors.map((color) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _selectedColor == color
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade300,
                                        width: _selectedColor == color ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        if (_selectedColor == color)
                                          BoxShadow(
                                            color: Colors.grey.shade300
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 2,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 내용 입력 필드
            TextField(
              controller: _contentController,
              maxLines: 3,
              maxLength: 30, // 30자로 제한
              decoration: InputDecoration(
                hintText: '공지사항 내용을 입력하세요 (최대 30자)',
                hintStyle: TextStyle(
                  color: AppColors.lightGray, // 원하는 색상으로 변경하세요
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        _isMaxLengthReached
                            ? AppColors.red
                            : AppColors.lightGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        _isMaxLengthReached ? AppColors.red : AppColors.primary,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        _isMaxLengthReached
                            ? AppColors.red
                            : Colors.grey.shade300,
                  ),
                ),
                fillColor: AppColors.background,
                filled: true,
                counterStyle: TextStyle(
                  color:
                      _isMaxLengthReached ? AppColors.red : AppColors.lightGray,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            // 중요 여부 토글
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '중요 공지사항',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                CustomSwitch(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 버튼 그룹 - 추가 버튼만 표시
            ElevatedButton(
              onPressed:
                  _contentController.text.trim().isNotEmpty
                      ? () {
                        // 공지사항 항목 생성
                        final newNotice = NoticeItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: _contentController.text.trim(),
                          color: _selectedColor,
                          isImportant: _isImportant,
                          createdAt: DateTime.now(),
                        );

                        // 콜백을 통해 상위 위젯에 새 공지사항 전달
                        widget.onNoticeCreated(newNotice);

                        // 바텀시트 닫기
                        Navigator.of(context).pop();
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '추가하기',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// 바텀시트 호출 도우미 함수
Future<void> showNoticeCreateBottomSheet({
  required BuildContext context,
  required List<Color> availableColors,
  required Function(NoticeItem) onNoticeCreated,
  int maxNoticeCount = 6,
}) async {
  final planId = ModalRoute.of(context)!.settings.arguments is Map<String, dynamic> 
      ? (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['planId'] as int? ?? 0
      : 0;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => NoticeCreateBottomSheet(
          availableColors: availableColors,
          onNoticeCreated: onNoticeCreated,
          planId: planId,
          maxNoticeCount: maxNoticeCount,
        ),
  );
}