import 'package:flutter/material.dart';
import '../../../models/plan/plan_model.dart';
import '../../../widgets/custom_switch.dart';
import 'plan_card.dart';
import '../../../config/theme.dart';

class PlanListView extends StatefulWidget {
  final List<Plan> plans;
  final Function(Plan) onPlanSelected;
  final Map<int, String>? treasurerNames;
  final Map<int, int>? memberCounts;

  const PlanListView({
    Key? key,
    required this.plans,
    required this.onPlanSelected,
    this.treasurerNames,
    this.memberCounts,
  }) : super(key: key);

  @override
  State<PlanListView> createState() => _PlanListViewState();
}

class _PlanListViewState extends State<PlanListView> {
  // 여행 상태별 필터링 설정 (기본값: 완료된 여행 제외)
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜 (시간 제외하고 날짜만)
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // 날짜 기준으로 정렬: 예정된 여행이 먼저 나오도록
    final sortedPlans = List<Plan>.from(widget.plans)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // 필터링된 플랜 목록
    final filteredPlans =
        sortedPlans.where((plan) {
          // 여행의 종료일 (시간 제외하고 날짜만)
          final planEndDate = DateTime(
            plan.endDate.year,
            plan.endDate.month,
            plan.endDate.day,
          );

          // 완료된 여행은 종료일이 오늘보다 이전인 경우만 해당
          // 오늘이 종료일인 경우는 아직 진행 중인 여행으로 간주
          final bool isCompleted = planEndDate.isBefore(todayDate);

          // 완료된 여행은 _showCompleted가 true일 때만 표시
          return _showCompleted || !isCompleted;
        }).toList();

    return Column(
      children: [
        // 필터 토글 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '완료된 여행 표시',
                style: const TextStyle(fontFamily: 'Anemone_air', fontSize: 14),
              ),
              const SizedBox(width: 8),
              CustomSwitch(
                value: _showCompleted,
                onChanged: (value) {
                  setState(() {
                    _showCompleted = value;
                  });
                },
              ),
            ],
          ),
        ),

        // 여행 목록 (한 줄에 하나씩 리스트 뷰)
        Expanded(
          child:
              filteredPlans.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flight_outlined,
                          size: 60,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '표시할 여행 계획이 없습니다',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 16,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = filteredPlans[index];

                      // 총무 이름과 멤버 수 가져오기
                      final treasurerName =
                          widget.treasurerNames != null
                              ? widget.treasurerNames![plan.planId]
                              : null;
                      final memberCount =
                          widget.memberCounts != null
                              ? widget.memberCounts![plan.planId]
                              : null;

                      return PlanCard(
                        plan: plan,
                        onTap: () {
                          // 계획 상세 화면으로 이동
                          Navigator.pushNamed(
                            context,
                            '/plan_detail',
                            arguments: {
                              'plan': plan,
                              'groupId': plan.groupId, // 계획이 속한 그룹 ID
                            },
                          );
                        },
                        treasurerName: treasurerName,
                        memberCount: memberCount,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
