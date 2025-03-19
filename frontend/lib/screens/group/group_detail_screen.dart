// screens/group/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/group_model.dart';
import '../../models/plan_model.dart';
import '../../providers/plan_provider.dart';
import 'widgets/group_calendar.dart';
import 'widgets/empty_plan_view.dart';
import 'widgets/plan_list_view.dart';
import 'widgets/plan_create_dialog.dart';
import 'widgets/calendar_event_bottom_sheet.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final plans = planProvider.getPlansForGroup(widget.group.groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 그룹 관리 메뉴 표시
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GroupCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              groupId: widget.group.groupId,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                _showCalendarEventBottomSheet(selectedDay);
              },
              eventLoader: (day) {
                return planProvider.getPlansForDate(widget.group.groupId, day);
              },
              onFocusedDayChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          // 여행 목록 영역 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '여행 계획',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _showAddPlanDialog(),
                ),
              ],
            ),
          ),

          // 여행 목록 또는 빈 상태 화면
          Expanded(
            child:
                plans.isEmpty
                    ? EmptyPlanView(onAddPlan: () => _showAddPlanDialog())
                    : PlanListView(
                      plans: plans,
                      onPlanSelected: (plan) {
                        // 여행 상세 화면으로 이동
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showCalendarEventBottomSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CalendarEventBottomSheet(
            groupId: widget.group.groupId,
            date: date,
          ),
    );
  }

  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => PlanCreateDialog(groupId: widget.group.groupId),
    );
  }
}
