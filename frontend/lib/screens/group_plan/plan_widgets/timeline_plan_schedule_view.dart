import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../config/theme.dart';
import '../bottomsheet/schedule_create_bottom_sheet.dart';
import './timeline_card.dart';
import './empty_schedule_view.dart';

class TimelinePlanScheduleView extends StatefulWidget {
  final Plan plan;
  final int groupId;

  const TimelinePlanScheduleView({
    Key? key,
    required this.plan,
    required this.groupId,
  }) : super(key: key);

  @override
  State<TimelinePlanScheduleView> createState() =>
      _TimelinePlanScheduleViewState();
}

class _TimelinePlanScheduleViewState extends State<TimelinePlanScheduleView> {
  List<PlanSchedule> _schedules = [];
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _travelDates = [];

  @override
  void initState() {
    super.initState();
    _generateTravelDates();
    if (_travelDates.isNotEmpty) {
      _selectedDate = _travelDates.first;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  void _generateTravelDates() {
    _travelDates.clear();
    DateTime currentDate = widget.plan.startDate;
    while (!currentDate.isAfter(widget.plan.endDate)) {
      _travelDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  Future<void> _loadSchedules() async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    planProvider.setLoading(true);

    try {
      // 실제 API 호출 코드
      final schedules = await planProvider.fetchPlanSchedules(
        widget.groupId,
        widget.plan.planId,
      );

      if (mounted) {
        setState(() {
          _schedules = schedules;
        });
      }
    } catch (e) {
      debugPrint('일정 데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _schedules = []; // 빈 목록으로 설정
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정을 불러오는데 실패했습니다. 나중에 다시 시도해주세요.'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: '재시도',
              onPressed: () => _loadSchedules(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        planProvider.setLoading(false);
      }
    }
  }

  List<PlanSchedule> _getSchedulesForSelectedDate() {
    return _schedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.visitAt.year,
          schedule.visitAt.month,
          schedule.visitAt.day,
        );
        final targetDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        return scheduleDate.isAtSameMomentAs(targetDate);
      }).toList()
      ..sort((a, b) => a.visitAt.compareTo(b.visitAt)); // 시간순 정렬
  }

  void _showAddScheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => ScheduleCreateBottomSheet(
            groupId: widget.groupId,
            planId: widget.plan.planId,
            initialDate: _selectedDate,
            onScheduleCreated: () {
              _loadSchedules();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택한 날짜의 일정 가져오기
    final currentDateSchedules = _getSchedulesForSelectedDate();
    final hasSchedules = currentDateSchedules.isNotEmpty;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // 날짜 선택 탭
          Container(
            height: 70,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _travelDates.length,
              itemBuilder: (context, index) {
                final date = _travelDates[index];
                final isSelected =
                    _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                final hasSchedules = _schedules.any((schedule) {
                  final scheduleDate = DateTime(
                    schedule.visitAt.year,
                    schedule.visitAt.month,
                    schedule.visitAt.day,
                  );
                  final targetDate = DateTime(date.year, date.month, date.day);
                  return scheduleDate.isAtSameMomentAs(targetDate);
                });

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'ko_KR').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.white : AppColors.darkGray,
                          ),
                        ),
                        if (hasSchedules)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 상단 정보 및 추가 버튼 (일정이 있을 때만 표시)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        'yyyy년 MM월 dd일',
                        'ko_KR',
                      ).format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '일정 ${currentDateSchedules.length}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
                // 동그란 버튼은 일정이 있을 때만 표시
                if (hasSchedules)
                  GestureDetector(
                    onTap: _showAddScheduleDialog,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.verylightGray,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightGray,
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.mediumGray,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 메인 타임라인 UI
          Expanded(child: _buildNewTimeline()),
        ],
      ),
    );
  }

  Widget _buildNewTimeline() {
    final schedules = _getSchedulesForSelectedDate();

    if (schedules.isEmpty) {
      return EmptyScheduleView(onAddScheduleTap: _showAddScheduleDialog);
    }

    // 컬러 팔레트
    final colors = [
      Color(0xFF4ECDC4), // 청록색
      Color(0xFFFFC857), // 노란색
      Color(0xFFFF6B6B), // 분홍색
      Color(0xFF45B7D1), // 하늘색
      Color(0xFF8BBD8B), // 연두색
      Color(0xFFAEA1EA), // 보라색
    ];

    // 중앙 타임라인 너비
    const double timelineWidth = 3.0;

    return Stack(
      children: [
        // 중앙 타임라인 - 끊김 없이 항상 표시 (색상을 회색으로 변경)
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(width: timelineWidth, color: AppColors.lightGray),
          ),
        ),

        // 일정 항목 스크롤 리스트
        ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20), // 여백만 약간 유지
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            final color = colors[index % colors.length];
            final isLeft = index % 2 == 0; // 좌/우 번갈아가며 배치

            return TimelineCard(
              schedule: schedule,
              color: color,
              isLeft: isLeft,
              groupId: widget.groupId,
              planId: widget.plan.planId,
              onScheduleDeleted: _loadSchedules,
              onScheduleUpdated: _loadSchedules, // 일정 수정 콜백 추가
            );
          },
        ),
      ],
    );
  }
}
