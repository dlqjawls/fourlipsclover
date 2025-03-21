// screens/group/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/group/group_model.dart';
import '../../models/plan_model.dart';
import '../../providers/plan_provider.dart';
import '../../config/theme.dart';
import 'widgets/group_calendar.dart';
import 'widgets/empty_plan_view.dart';
import 'widgets/plan_list_view.dart';
import 'widgets/plan_create_dialog.dart';
import 'widgets/calendar_event_bottom_sheet.dart';
import 'widgets/group_members_bar.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0; // 0: 캘린더, 1: 여행계획, 2: 앨범

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final plans = planProvider.getPlansForGroup(widget.group.groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.group.name,
          style: TextStyle(
            fontFamily: 'Anemone',
            fontSize: 30,
            color: AppColors.primaryDark, // 테마 색상으로 변경
          ),
        ),
        centerTitle: true,
        elevation: 0, // 그림자 제거
      ),
      body: Column(
        children: [
          // 그룹 멤버 바 추가
          GroupMembersBar(
            onAddMember: () {
              // TODO: 멤버 초대 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('카카오톡으로 친구를 초대합니다.')),
              );
            },
          ),

          // 상단 탭 버튼
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton('캘린더', 0, Icons.calendar_today),
                _buildTabButton('여행계획', 1, Icons.list_alt),
                _buildTabButton('공동앨범', 2, Icons.photo_library),
              ],
            ),
          ),

          // 선택된 탭에 따른 컨텐츠
          Expanded(child: _buildSelectedView(plans)),
        ],
      ),
      // FloatingActionButton 완전히 제거
      floatingActionButton: null,
    );
  }

  // 탭 버튼 위젯
  Widget _buildTabButton(String title, int index, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 선택된 탭에 따른 컨텐츠 빌드
  Widget _buildSelectedView(List<Plan> plans) {
    switch (_selectedIndex) {
      case 0: // 캘린더
        return Padding(
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
              return Provider.of<PlanProvider>(
                context,
                listen: false,
              ).getPlansForDate(widget.group.groupId, day);
            },
            onFocusedDayChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        );

      case 1: // 여행계획
        return Column(
          children: [
            // 여행 목록 영역 제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '여행 계획',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  // 계획이 있을 때만 버튼 표시
                  if (plans.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showAddPlanDialog(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.verylightGray,
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 2.0,
                          ),
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
        );

      case 2: // 앨범
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library,
                size: 80,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '공동 앨범',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '앨범 기능이 곧 추가될 예정입니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );

      default:
        return Container();
    }
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
