import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../models/plan/plan_model.dart';
import '../../../config/theme.dart';
import '../../../providers/plan_provider.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;
  final PlanProvider? planProvider;
  final String? treasurerName;
  final int? memberCount;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.onTap,
    this.planProvider,
    this.treasurerName,
    this.memberCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜 (시간 제외하고 날짜만)
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // 여행 날짜도 시간 제외하고 날짜만
    final planStartDate = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );
    final planEndDate = DateTime(
      plan.endDate.year,
      plan.endDate.month,
      plan.endDate.day,
    );

    // 여행 상태 확인 (완료/진행 중/예정)
    // 오늘이 종료일인 경우는 아직 진행 중인 여행으로 간주
    final bool isCompleted = planEndDate.isBefore(todayDate);
    final bool isOngoing =
        !isCompleted &&
        (planStartDate.isBefore(todayDate) ||
            planStartDate.isAtSameMomentAs(todayDate));

    // 상태에 따른 색상 및 아이콘 결정
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCompleted) {
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle;
      statusText = '완료';
    } else if (isOngoing) {
      statusColor = AppColors.primaryDark; // 진행 중은 진한 색상
      statusIcon = Icons.directions_run;
      statusText = '진행 중';
    } else {
      statusColor = AppColors.primary; // 예정은 primary 색상으로 변경
      statusIcon = Icons.flight_takeoff;
      statusText = '예정';
    }

    // 총무 이름 가져오기
    final String displayTreasurerName =
        treasurerName ??
        (planProvider != null
            ? planProvider!.getTreasurerNickname(plan.planId)
            : '총무');

    // 인원수 가져오기
    final int displayMemberCount =
        memberCount ??
        (planProvider != null
            ? planProvider!.getPlanMemberCount(plan.planId)
            : 0);

    return Card(
      elevation: isOngoing ? 5 : 4, // 진행 중인 여행은 그림자 더 강하게
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(isOngoing ? 0.8 : 0.5),
          width: isOngoing ? 2.0 : 1.5, // 진행 중인 여행은 테두리 더 두껍게
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 150, // 높이 제한
          child: Row(
            children: [
              // 왼쪽: 날짜 영역 (너비 증가)
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 시작 날짜 - SingleChildScrollView로 감싸서 오버플로우 방지
                    Text(
                      DateFormat('MM.dd').format(plan.startDate),
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 18, // 글꼴 크기 약간 줄임
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // 점선 구분선
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DashedLinePainter(
                          color: statusColor.withOpacity(0.5),
                        ),
                      ),
                    ),

                    // 종료 날짜
                    Text(
                      DateFormat('MM.dd').format(plan.endDate),
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 18, // 글꼴 크기 약간 줄임
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10), // 간격 증가
                    // D-day 또는 D+day (크기 축소)
                    Container(
                      width: double.infinity, // 너비를 전체로 설정
                      child: Center(
                        child: _buildDdayBadge(
                          planStartDate,
                          planEndDate,
                          todayDate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 점선 분리선
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: DashedLinePainter(
                  color: statusColor.withOpacity(0.5),
                  isVertical: true,
                ),
              ),

              // 여백 추가
              const SizedBox(width: 5),

              // 바코드 영역
              Container(
                width: 25,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: RotatedBox(
                  quarterTurns: 3, // 바코드를 세로로 회전
                  child: _buildDenseBarcode(statusColor),
                ),
              ),

              // 여백 추가
              const SizedBox(width: 5),

              // 오른쪽: 상세 정보 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단: 여행 제목과 상태
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목
                          Expanded(
                            child: Text(
                              plan.title,
                              style: const TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // 상태 아이콘
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
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
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // 진행 중인 여행에 NOW 표시 추가
                                if (isOngoing) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'NOW',
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // 여행 설명
                      Expanded(
                        child: Text(
                          plan.description,
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 하단: 인원수 및 총무 정보
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 인원 수
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${displayMemberCount}명',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                          ),

                          // 구분점
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),

                          // 총무 정보
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 14,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '총무: $displayTreasurerName',
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 12,
                                color: AppColors.darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 오른쪽 끝: 티켓 디자인 완성용 구멍 패턴
              _buildTicketPattern(statusColor),
            ],
          ),
        ),
      ),
    );
  }

  // 티켓 패턴 생성 (오른쪽 끝 점선 또는 구멍 패턴)
  Widget _buildTicketPattern(Color statusColor) {
    return Container(
      width: 15,
      child: Column(
        children: List.generate(
          8,
          (index) => Expanded(
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 더 촘촘한 바코드 생성 위젯
  Widget _buildDenseBarcode(Color statusColor) {
    final random = math.Random(plan.planId.hashCode); // 동일한 계획은 동일한 바코드 생성

    return Container(
      height: 80, // 높이 증가
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          80, // 바코드 라인 수 증가
          (index) => Container(
            width: 1.0,
            height: double.infinity,
            color:
                random.nextDouble() <
                        0.7 // 70% 확률로 검정색 선
                    ? AppColors.darkGray.withOpacity(0.9)
                    : Colors.transparent,
          ),
        ),
      ),
    );
  }

  // D-day 또는 D+day 배지 생성 (크기 축소)
  Widget _buildDdayBadge(DateTime startDate, DateTime endDate, DateTime today) {
    String text;
    Color color;

    if (today.isBefore(startDate)) {
      // 여행 시작 전: D-day
      final difference = startDate.difference(today);
      final daysUntil = difference.inDays;

      // 0일이 남았을 경우 D-1로 표시 (당일로 간주)
      final displayDays = daysUntil == 0 ? 1 : daysUntil;
      text = 'D-$displayDays';
      color = AppColors.primary; // primary 색상으로 변경
    } else if (today.isAfter(endDate)) {
      // 여행 종료 후: 표시 안함
      return const SizedBox.shrink();
    } else {
      // 여행 중: D+day
      final daysInto = today.difference(startDate).inDays;
      text = 'D+$daysInto';
      color = AppColors.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Anemone_air',
          fontSize: 9, // 글꼴 크기 축소
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// 점선 그리기 위한 CustomPainter
class DashedLinePainter extends CustomPainter {
  final Color color;
  final bool isVertical;

  DashedLinePainter({required this.color, this.isVertical = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final dashWidth = 3.0;
    final dashSpace = 3.0;

    if (isVertical) {
      // 세로 점선
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(0, startY),
          Offset(0, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    } else {
      // 가로 점선
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX + dashWidth, 0),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
