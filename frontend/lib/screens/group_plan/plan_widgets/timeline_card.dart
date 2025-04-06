import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../config/theme.dart';
import '../bottomsheet/schedule_detail_bottom_sheet.dart';

// 타임라인 카드 위젯으로 분리
class TimelineCard extends StatelessWidget {
  final PlanSchedule schedule;
  final Color color;
  final bool isLeft;
  final int groupId;
  final int planId;
  final VoidCallback onScheduleDeleted;
  final VoidCallback onScheduleUpdated;
  final DateTime startDate; // 여행 시작일 추가
  final DateTime endDate;   // 여행 종료일 추가

  const TimelineCard({
    Key? key,
    required this.schedule,
    required this.color,
    required this.isLeft,
    required this.groupId,
    required this.planId,
    required this.onScheduleDeleted,
    required this.onScheduleUpdated,
    required this.startDate,  // 필수 매개변수로 추가
    required this.endDate,    // 필수 매개변수로 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('HH:mm').format(schedule.visitAt);

    // 카드 내용물 - 전체 터치 가능하게 GestureDetector 추가
    final cardContent = GestureDetector(
      onTap: () => _showScheduleDetailBottomSheet(context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: color, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    schedule.placeName ?? '알 수 없는 장소',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (schedule.notes != null && schedule.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  schedule.notes!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );

    // 타임라인 점
    final timelineDot = Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          isLeft
              ? [
                cardContent,
                _buildDashedLine(context, color),
                timelineDot,
                SizedBox(width: MediaQuery.of(context).size.width * 0.425),
              ]
              : [
                SizedBox(width: MediaQuery.of(context).size.width * 0.427),
                timelineDot,
                _buildDashedLine(context, color),
                cardContent,
              ],
    );
  }

  // 일정 상세 정보 바텀시트 표시
  void _showScheduleDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailBottomSheet(
        groupId: groupId,
        planId: planId,
        schedule: schedule,
        onScheduleUpdated: onScheduleUpdated,
        onScheduleDeleted: onScheduleDeleted,
        color: color,
        startDate: startDate, // 여행 시작일 전달
        endDate: endDate,     // 여행 종료일 전달
      ),
    );
  }

  // 점선 연결
  Widget _buildDashedLine(BuildContext context, Color color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1 - 10,
      child: CustomPaint(
        painter: DashedLinePainter(color: color),
        child: Container(height: 2),
      ),
    );
  }
}

// 점선 그리기 위한 커스텀 페인터
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4;
    const dashSpace = 3;

    double startX = 0;
    final double endX = size.width;

    while (startX < endX) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}