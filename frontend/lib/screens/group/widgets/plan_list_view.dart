import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plan_model.dart';
import '../../../config/theme.dart';

class PlanListView extends StatelessWidget {
  final List<Plan> plans;
  final Function(Plan) onPlanSelected;
  
  const PlanListView({
    Key? key,
    required this.plans,
    required this.onPlanSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onPlanSelected(plan),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 - 제목과 날짜
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plan.title,
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatDateRange(plan.startDate, plan.endDate),
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 12,
                            color: AppColors.primaryDarkest,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 설명
                  Text(
                    plan.description,
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 하단 - 생성 정보 및 아이콘
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '생성일: ${DateFormat('yyyy.MM.dd').format(plan.createdAt)}',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 12,
                          color: AppColors.lightGray,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.mediumGray,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MM.dd');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}