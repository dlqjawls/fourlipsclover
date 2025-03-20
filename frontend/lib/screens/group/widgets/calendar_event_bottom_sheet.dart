import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan_model.dart';
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
    final plans = planProvider.getPlansForDate(groupId, date);
    final planPlaces = planProvider.getPlanPlacesForDate(groupId, date);
    
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
            child: planPlaces.isEmpty 
              ? _buildEmptyState(plans)
              : _buildEventList(planPlaces),
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
  
  Widget _buildEmptyState(List<Plan> plans) {
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
  
  Widget _buildEventList(List<PlanPlace> planPlaces) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: planPlaces.length,
      itemBuilder: (context, index) {
        final planPlace = planPlaces[index];
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
                        planPlace.place.name,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        planPlace.notes,
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
                  DateFormat('HH:mm').format(planPlace.visitAt),
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