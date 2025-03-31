import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../config/theme.dart';
import './schedule_update_bottom_sheet.dart';

class ScheduleDetailBottomSheet extends StatelessWidget {
  final int groupId;
  final int planId;
  final PlanSchedule schedule;
  final VoidCallback onScheduleUpdated;
  final VoidCallback onScheduleDeleted;
  final Color color;

  const ScheduleDetailBottomSheet({
    Key? key,
    required this.groupId,
    required this.planId,
    required this.schedule,
    required this.onScheduleUpdated,
    required this.onScheduleDeleted,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final timeFormat = DateFormat('HH:mm');

    // 방문 날짜 및 시간 형식화
    final visitDate = dateFormat.format(schedule.visitAt);
    final visitTime = timeFormat.format(schedule.visitAt);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '일정 상세 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                // X 버튼 대신 휴지통 아이콘
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.darkGray,
                  ),
                  onPressed: () => _confirmDeleteSchedule(context),
                ),
              ],
            ),
            const Divider(color: AppColors.lightGray),
            const SizedBox(height: 16),

            // 장소 이름
            _detailSection(
              context,
              '장소',
              schedule.placeName ?? '알 수 없는 장소',
              Icons.place,
              color,
            ),
            const SizedBox(height: 20),

            // 방문 날짜
            _detailSection(
              context,
              '날짜',
              visitDate,
              Icons.calendar_today,
              color,
            ),
            const SizedBox(height: 20),

            // 방문 시간
            _detailSection(context, '시간', visitTime, Icons.access_time, color),
            const SizedBox(height: 20),

            // 메모
            if (schedule.notes != null && schedule.notes!.isNotEmpty)
              _detailSection(context, '메모', schedule.notes!, Icons.note, color),

            const SizedBox(height: 32),

            // 수정하기 버튼만 남기고 길게 만듦
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _editSchedule(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '수정하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 상세 정보 섹션 위젯
  Widget _detailSection(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
          ),
        ),
      ],
    );
  }

  // 수정 바텀시트 표시
  void _editSchedule(BuildContext context) {
    // 상세 정보 바텀시트 닫기
    Navigator.pop(context);

    // 수정 바텀시트 표시
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

  // 삭제 확인 다이얼로그
  Future<void> _confirmDeleteSchedule(BuildContext context) async {
    final placeNameText = schedule.placeName ?? '알 수 없는 장소';

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('일정 삭제'),
            content: Text('$placeNameText 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // 상세 정보 바텀시트 닫기
      Navigator.pop(context);

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
    } else {
      // 취소한 경우에는 바텀시트를 닫지 않음
    }
  }
}
