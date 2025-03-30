import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../config/theme.dart';
import '../bottomsheet/schedule_update_bottom_sheet.dart';

// 타임라인 카드 위젯으로 분리
class TimelineCard extends StatelessWidget {
  final PlanSchedule schedule;
  final Color color;
  final bool isLeft;
  final int groupId;
  final int planId;
  final VoidCallback onScheduleDeleted;
  final VoidCallback onScheduleUpdated;

  const TimelineCard({
    Key? key,
    required this.schedule,
    required this.color,
    required this.isLeft,
    required this.groupId,
    required this.planId,
    required this.onScheduleDeleted,
    required this.onScheduleUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('HH:mm').format(schedule.visitAt);

    // 카드 내용물
    final cardContent = Container(
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
                  schedule.placeName,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showUpdateScheduleBottomSheet(context),
                child: Icon(Icons.edit, color: Colors.grey.shade400, size: 16),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _confirmDeleteSchedule(context),
                child: Icon(
                  Icons.delete,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
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

  // 수정 바텀시트 표시
  void _showUpdateScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => ScheduleUpdateBottomSheet(
            groupId: groupId,
            planId: planId,
            schedule: schedule,
            onScheduleUpdated: onScheduleUpdated,
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

  // 삭제 확인 다이얼로그
  Future<void> _confirmDeleteSchedule(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('일정 삭제'),
            content: Text('${schedule.placeName} 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      planProvider.setLoading(true);

      try {
        await planProvider.deletePlanSchedule(
          groupId,
          planId,
          schedule.planScheduleId,
        );

        onScheduleDeleted();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('일정 삭제에 실패했습니다: $e')));
        }
      } finally {
        planProvider.setLoading(false);
      }
    }
  }
}

// 점선 그리기 위한 커스텀 페인터
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
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
