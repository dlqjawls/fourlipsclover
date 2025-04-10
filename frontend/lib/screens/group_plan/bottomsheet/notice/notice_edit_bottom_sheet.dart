// lib/screens/plan/bottomsheet/notice_edit_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../models/notice/notice_model.dart';
import '../../../../widgets/custom_switch.dart'; // 커스텀 스위치 임포트

class NoticeEditItem {
  final bool isImportant;
  final Color color;
  final String content;

  NoticeEditItem({
    required this.isImportant,
    required this.color,
    required this.content,
  });
}

Future<void> showNoticeEditBottomSheet({
  required BuildContext context,
  required NoticeModel notice,
  required List<Color> availableColors,
  required Function(NoticeEditItem) onNoticeUpdated,
  required Function() onNoticeDeleted,
}) {
  final TextEditingController contentController = TextEditingController(
    text: notice.content,
  );
  bool isImportant = notice.isImportant;
  Color selectedColor = AppColors.noticeMemoYellow; // 기본 색상

  // 현재 선택된 색상을 설정
  switch (notice.color) {
    case NoticeColor.YELLOW:
      selectedColor = AppColors.noticeMemoYellow;
      break;
    case NoticeColor.RED:
      selectedColor = AppColors.noticeMemoRed;
      break;
    case NoticeColor.BLUE:
      selectedColor = AppColors.noticeMemoBlue;
      break;
    case NoticeColor.GREEN:
      selectedColor = AppColors.noticeMemoGreen;
      break;
    case NoticeColor.ORANGE:
      selectedColor = AppColors.noticeMemoOrange;
      break;
    case NoticeColor.VIOLET:
      selectedColor = AppColors.noticeMemoViolet;
      break;
  }

  // 글자 수 제한 체크 함수
  bool isMaxLengthReached() => contentController.text.length >= 30;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
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
                    '공지사항 수정',
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
                          color: selectedColor,
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
                                  if (isImportant)
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
                                      contentController.text.isEmpty
                                          ? '공지사항 내용을 입력하세요'
                                          : contentController.text,
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
                                        isImportant
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
                                    availableColors.map((color) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedColor = color;
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
                                                  selectedColor == color
                                                      ? Colors.grey.shade500
                                                      : Colors.grey.shade300,
                                              width:
                                                  selectedColor == color
                                                      ? 2
                                                      : 1,
                                            ),
                                            boxShadow: [
                                              if (selectedColor == color)
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
                    controller: contentController,
                    maxLines: 3,
                    maxLength: 30, // 30자로 제한
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: '공지사항 내용을 입력하세요 (최대 30자)',
                      hintStyle: TextStyle(color: AppColors.lightGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              isMaxLengthReached()
                                  ? AppColors.red
                                  : AppColors.lightGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              isMaxLengthReached()
                                  ? AppColors.red
                                  : AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              isMaxLengthReached()
                                  ? AppColors.red
                                  : Colors.grey.shade300,
                        ),
                      ),
                      fillColor: AppColors.background,
                      filled: true,
                      counterStyle: TextStyle(
                        color:
                            isMaxLengthReached()
                                ? AppColors.red
                                : AppColors.lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 중요 여부 토글
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '중요 공지사항',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CustomSwitch(
                        value: isImportant,
                        onChanged: (value) {
                          setState(() {
                            isImportant = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 버튼 영역 (삭제, 취소, 저장)
                  Row(
                    children: [
                      // 삭제 버튼
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 삭제 확인 다이얼로그 표시
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('공지사항 삭제'),
                                    content: const Text('이 공지사항을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // 다이얼로그 닫기
                                          Navigator.pop(context); // 바텀시트 닫기
                                          onNoticeDeleted(); // 삭제 콜백 실행
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('삭제'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 저장 버튼
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              contentController.text.trim().isNotEmpty
                                  ? () {
                                    // 수정된 공지사항 생성
                                    final updatedNotice = NoticeEditItem(
                                      isImportant: isImportant,
                                      color: selectedColor,
                                      content: contentController.text.trim(),
                                    );

                                    onNoticeUpdated(updatedNotice);
                                    Navigator.pop(context);
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '수정',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
