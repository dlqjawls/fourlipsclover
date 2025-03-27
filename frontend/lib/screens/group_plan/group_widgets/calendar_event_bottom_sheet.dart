import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan/plan_list_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';

class CalendarEventBottomSheet extends StatefulWidget {
  final int groupId;
  final DateTime date;
  
  const CalendarEventBottomSheet({
    Key? key,
    required this.groupId,
    required this.date,
  }) : super(key: key);
  
  @override
  _CalendarEventBottomSheetState createState() => _CalendarEventBottomSheetState();
}

class _CalendarEventBottomSheetState extends State<CalendarEventBottomSheet> {
  List<PlanList>? _plans;
  List<PlanSchedule>? _schedules;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    
    try {
      // 1. 계획 로드
      final plans = await planProvider.fetchPlans(widget.groupId);
      final plansForDate = plans.where((plan) {
        return !widget.date.isBefore(plan.startDate) && 
               !widget.date.isAfter(plan.endDate.add(const Duration(days: 1)));
      }).toList();
      
      // 2. 일정 로드
      List<PlanSchedule> schedulesForDate = [];
      for (var plan in plansForDate) {
        final schedules = await planProvider.fetchPlanSchedules(widget.groupId, plan.planId);
        
        // 해당 날짜에 속하는 일정만 필터링
        final filteredSchedules = schedules.where((schedule) {
          final scheduleDate = DateTime(
            schedule.visitAt.year,
            schedule.visitAt.month,
            schedule.visitAt.day,
          );
          final targetDate = DateTime(
            widget.date.year,
            widget.date.month,
            widget.date.day,
          );
          return scheduleDate.isAtSameMomentAs(targetDate);
        }).toList();
        
        schedulesForDate.addAll(filteredSchedules);
      }
      
      // 방문 시간순으로 정렬
      schedulesForDate.sort((a, b) => a.visitAt.compareTo(b.visitAt));
      
      // 데이터 설정 (상태 업데이트)
      if (mounted) {
        setState(() {
          _plans = plansForDate;
          _schedules = schedulesForDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _plans = [];
          _schedules = [];
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 날짜 표시
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              DateFormat('yyyy년 MM월 dd일').format(widget.date),
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ),
          
          const Divider(height: 1, thickness: 1),
          
          // 이벤트 목록 또는 빈 상태
          Expanded(
            child: (_schedules?.isEmpty ?? true) 
              ? _buildEmptyState(_plans ?? [])
              : _buildEventList(_schedules!),
          ),
          
          // 하단 버튼
          if (_plans?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // 세부 일정 추가 화면으로 이동
                  // TODO: 일정 추가 화면으로 이동하는 코드 추가
                },
                child: const Text(
                  '세부 일정 추가',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(List<PlanList> plans) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 48,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            plans.isEmpty 
              ? '이 날짜에 계획된 여행이 없어요' 
              : '세부 일정이 없어요',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          if (plans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '세부 일정을 추가해보세요',
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEventList(List<PlanSchedule> schedules) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.placeName,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.notes ?? '메모 없음',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(schedule.visitAt),
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}