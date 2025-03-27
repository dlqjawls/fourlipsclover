import 'package:flutter/material.dart';
import '../../../models/plan/plan_model.dart';
import 'plan_card.dart';

class PlanListView extends StatefulWidget {
  final List<Plan> plans;
  final Function(Plan) onPlanSelected;

  const PlanListView({
    Key? key,
    required this.plans,
    required this.onPlanSelected,
  }) : super(key: key);

  @override
  State<PlanListView> createState() => _PlanListViewState();
}

class _PlanListViewState extends State<PlanListView> {
  // 여행 상태별 필터링 설정 (기본값: 완료된 여행 제외)
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜
    final now = DateTime.now();

    // 날짜 기준으로 정렬: 예정된 여행이 먼저 나오도록
    final sortedPlans = List<Plan>.from(widget.plans)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // 필터링된 플랜 목록
    final filteredPlans = sortedPlans.where((plan) {
      final bool isCompleted = plan.endDate.isBefore(now);
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
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 14,
                ),
              ),
              Switch(
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

        // 여행 목록 그리드
        Expanded(
          child: filteredPlans.isEmpty
              ? Center(
                  child: Text(
                    '표시할 여행 계획이 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 16,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 한 줄에 두 개의 카드
                    crossAxisSpacing: 16, // 가로 간격
                    mainAxisSpacing: 16, // 세로 간격
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
                    return PlanCard(
                      plan: plan,
                      onTap: () => widget.onPlanSelected(plan),
                    );
                  },
                ),
        ),
      ],
    );
  }
}