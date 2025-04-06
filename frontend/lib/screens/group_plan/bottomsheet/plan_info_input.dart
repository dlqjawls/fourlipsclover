import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';

class PlanInfoInput extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int selectedMemberCount;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isTitleEmpty;

  const PlanInfoInput({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.selectedMemberCount,
    required this.titleController,
    required this.descriptionController,
    this.isTitleEmpty = false,
  }) : super(key: key);

  @override
  State<PlanInfoInput> createState() => _PlanInfoInputState();
}

class _PlanInfoInputState extends State<PlanInfoInput> {
  @override
  Widget build(BuildContext context) {
    // 여행 일수 계산
    final int daysDiff = widget.endDate.difference(widget.startDate).inDays + 1;
    final String tripDuration = "${daysDiff - 1}박 ${daysDiff}일";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 티켓 형태의 정보 요약
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 티켓 상단 부분
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '여행 티켓',
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('yyyy년 MM월 dd일').format(widget.startDate)} - ${DateFormat('yyyy년 MM월 dd일').format(widget.endDate)}',
                              style: const TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 점선 구분선 (티켓 절취선)
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 10).floor(),
                          (index) => Container(
                            width: 5,
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 티켓 하단 부분 (탑승 정보)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 멤버 정보
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '탑승 인원',
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 12,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.selectedMemberCount}명',
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // 기간 정보 (2박 3일 형식으로 변경)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '여행 기간',
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 12,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tripDuration,
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 여행명 라벨
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '여행명',
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ),

          // 여행명 입력 필드 (힌트 텍스트 색상 변경)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.titleController,
              style: const TextStyle(fontFamily: 'Anemone_air'),
              decoration: InputDecoration(
                hintText: '어떤 여행인가요? (예: 부산 힐링 여행)',
                hintStyle: TextStyle(
                  color: AppColors.lightGray,
                  fontFamily: 'Anemone_air',
                ),
                errorText: widget.isTitleEmpty ? '제목을 입력해주세요' : null,
                errorStyle: TextStyle(
                  color: AppColors.red,
                  fontFamily: 'Anemone_air',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              maxLength: 30,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                    textAlign: TextAlign.end,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 귀여운 클로버 이미지 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 30.0),
                child: Image.asset(
                  'assets/images/cute_clover.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
