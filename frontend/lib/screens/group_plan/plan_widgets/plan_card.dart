import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plan/plan_model.dart';
import '../../../config/theme.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜
    final now = DateTime.now();

    // 여행 상태 확인 (완료/진행 중/예정)
    final bool isCompleted = plan.endDate.isBefore(now);
    final bool isOngoing = !isCompleted && plan.startDate.isBefore(now);
    final bool isUpcoming = plan.startDate.isAfter(now);

    // 상태에 따른 색상 및 아이콘 결정
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCompleted) {
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle;
      statusText = '완료';
    } else if (isOngoing) {
      statusColor = AppColors.primaryDark;
      statusIcon = Icons.directions_run;
      statusText = '진행 중';
    } else {
      statusColor = AppColors.orange; // 추천 주황색
      statusIcon = Icons.flight_takeoff;
      statusText = '예정';
    }

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias, // 둥근 모서리 내부로 자식 위젯 클리핑
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단부 - 컬러 배경, 제목 및 상태
            Container(
              color: statusColor.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 영역
                  Expanded(
                    child: Text(
                      plan.title,
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 상태 배지
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 하단부 - 흰색 배경, 상세 정보
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 여행 날짜 및 D-day
                    Row(
                      children: [
                        // 여행 날짜
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatDateRange(plan.startDate, plan.endDate),
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // D-day 또는 D+day
                        _buildDdayBadge(plan.startDate, plan.endDate, now),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 여행 상세 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 인원 수 표시
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 12,
                                color: AppColors.darkGray,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${plan.memberIds.length}명',
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 10,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // 여행 설명
                          Expanded(
                            child: Text(
                              plan.description,
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // D-day 또는 D+day 배지 생성 (수정된 버전)
  Widget _buildDdayBadge(DateTime startDate, DateTime endDate, DateTime now) {
    String text;
    Color color;

    if (now.isBefore(startDate)) {
      // 여행 시작 전: D-day
      final difference = startDate.difference(now);
      final daysUntil = difference.inDays + (difference.inHours % 24 > 0 ? 1 : 0);
      
      // 0일이 남았을 경우 D-1로 표시 (당일로 간주)
      final displayDays = daysUntil == 0 ? 1 : daysUntil;
      text = 'D-$displayDays';
      color = AppColors.orange;
    } else if (now.isAfter(endDate)) {
      // 여행 종료 후: 표시 안함
      return const SizedBox.shrink();
    } else {
      // 여행 중: D+day
      final daysInto = now.difference(startDate).inDays;
      text = 'D+$daysInto';
      color = AppColors.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Anemone_air',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MM.dd');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}