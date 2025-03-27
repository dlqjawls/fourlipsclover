import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan/plan_list_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';

class CalendarEventBottomSheet extends StatelessWidget {
  final int groupId;
  final DateTime date;
  
  const CalendarEventBottomSheet({
    Key? key,
    required this.groupId,
    required this.date,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    
    // 비동기 데이터를 처리하기 위한 FutureBuilder 사용
    return FutureBuilder<List<PlanList>>(
      future: planProvider.getPlansForDate(groupId, date),
      builder: (context, plansSnapshot) {
        if (plansSnapshot.connectionState == ConnectionState.waiting) {
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
        
        final plans = plansSnapshot.data ?? [];
        
        return FutureBuilder<List<PlanSchedule>>(
          future: planProvider.getSchedulesForDate(groupId, date),
          builder: (context, schedulesSnapshot) {
            if (schedulesSnapshot.connectionState == ConnectionState.waiting) {
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
            
            final schedules = schedulesSnapshot.data ?? [];
            
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
                      DateFormat('yyyy년 MM월 dd일').format(date),
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
                    child: schedules.isEmpty 
                      ? _buildEmptyState(plans)
                      : _buildEventList(schedules),
                  ),
                  
                  // 하단 버튼
                  if (plans.isNotEmpty)
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
          },
        );
      },
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