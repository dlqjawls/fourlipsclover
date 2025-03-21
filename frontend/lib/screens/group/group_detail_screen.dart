// screens/group/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/group/group_model.dart';
import '../../models/group/group_detail_model.dart';
import '../../models/plan_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/group_provider.dart';
import '../../config/theme.dart';
import 'widgets/group_calendar.dart';
import 'widgets/empty_plan_view.dart';
import 'widgets/plan_list_view.dart';
import 'widgets/plan_create_dialog.dart';
import 'widgets/calendar_event_bottom_sheet.dart';
import 'widgets/group_members_bar.dart';
import 'widgets/group_edit_dialog.dart';

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
  late Group _currentGroup;

  // 그룹 상세 정보 및 멤버 데이터
  GroupDetail? _groupDetail;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;

    // 빌드가 완료된 후 그룹 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupDetail();
    });
  }

  // 그룹 상세 정보 로드
  Future<void> _loadGroupDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final detail = await groupProvider.fetchGroupDetail(_currentGroup.groupId);

    if (mounted) {
      // 위젯이 아직 마운트 상태인지 확인
      setState(() {
        _groupDetail = detail;
        _isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final plans = planProvider.getPlansForGroup(_currentGroup.groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentGroup.name,
          style: TextStyle(
            fontFamily: 'Anemone',
            fontSize: 30,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 그룹장인 경우에만 메뉴 버튼 표시
          if (isGroupOwner())
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditGroupDialog();
                } else if (value == 'delete') {
                  _showDeleteConfirmDialog();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.primaryDark),
                          SizedBox(width: 8),
                          Text('그룹 정보 수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('그룹 삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body:
          groupProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // 그룹 멤버 바 추가
                  _isLoadingDetail || _groupDetail == null
                      ? SizedBox(
                        height: 86,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                      : GroupMembersBar(
                        members: _groupDetail!.members,
                        currentUserId: _getMyUserId(), // 사용자 ID 가져오기
                        onAddMember: () async {
                          // 초대 링크 생성 및 공유 기능
                          final groupProvider = Provider.of<GroupProvider>(
                            context,
                            listen: false,
                          );

                          // 로딩 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('초대 링크 생성 중...')),
                          );

                          // 초대 링크 생성
                          final inviteUrl = await groupProvider
                              .generateInviteLink(_currentGroup.groupId);

                          if (inviteUrl != null) {
                            // TODO: 생성된 초대 링크를 공유하는 기능 구현
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('초대 링크가 생성되었습니다: $inviteUrl'),
                                action: SnackBarAction(
                                  label: '복사',
                                  onPressed: () {
                                    // TODO: 클립보드에 복사하는 기능 구현
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '초대 링크 생성 실패: ${groupProvider.error}',
                                ),
                              ),
                            );
                          }
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
      floatingActionButton: null,
    );
  }

  // 탭 버튼 위젯 (변경 없음)
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

  // 선택된 탭에 따른 컨텐츠 빌드 (변경 없음)
  Widget _buildSelectedView(List<Plan> plans) {
    switch (_selectedIndex) {
      case 0: // 캘린더
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GroupCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            groupId: _currentGroup.groupId,
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
              ).getPlansForDate(_currentGroup.groupId, day);
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

  // 캘린더 이벤트 바텀시트 표시 (변경 없음)
  void _showCalendarEventBottomSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CalendarEventBottomSheet(
            groupId: _currentGroup.groupId,
            date: date,
          ),
    );
  }

  // 여행 계획 추가 다이얼로그 표시 (변경 없음)
  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => PlanCreateDialog(groupId: _currentGroup.groupId),
    );
  }

  // 그룹 정보 수정 다이얼로그 표시 (새로 추가)
  void _showEditGroupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => GroupEditDialog(
            group: _currentGroup,
            onUpdate: (updatedGroup) {
              setState(() {
                _currentGroup = updatedGroup;
              });
            },
          ),
    );
  }

  // 그룹 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('그룹 삭제'),
            content: Text('정말로 "${_currentGroup.name}" 그룹을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteGroup();
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // 그룹 삭제 실행
  Future<void> _deleteGroup() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    try {
      debugPrint('그룹 삭제 요청 시작: groupId=${_currentGroup.groupId}');
      final success = await groupProvider.deleteGroup(_currentGroup.groupId);
      debugPrint('그룹 삭제 응답: success=$success, error=${groupProvider.error}');

      if (success) {
        // 삭제 성공 후 이전 화면으로 이동
        Navigator.of(context).pop();

        // 그룹 목록 화면에서 목록 새로고침 요청
        Future.delayed(Duration(milliseconds: 500), () {
          Provider.of<GroupProvider>(context, listen: false).fetchMyGroups();
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('그룹이 삭제되었습니다.')));
      }
    } catch (e) {
      debugPrint('그룹 삭제 중 예외 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('그룹 삭제 중 오류 발생: $e')));
    }
  }

  // 현재 로그인한 사용자의 ID 가져오기
  // 참고: 실제로는 로그인 상태나 사용자 Provider에서 가져와야 합니다.
  int _getMyUserId() {
    // TODO: 실제 로그인한 사용자 ID를 반환하는 로직으로 대체
    // 현재는 그룹 멤버 중 첫번째 멤버가 현재 사용자라고 가정
    if (_groupDetail != null && _groupDetail!.members.isNotEmpty) {
      return _groupDetail!.members.first.memberId;
    }
    return 1; // 기본값
  }

  bool isGroupOwner() {
    // 현재 로그인한 사용자 ID 가져오기
    final myId = _getMyUserId();

    // 그룹 생성자 ID와 비교
    final isOwner = _currentGroup.memberId == myId;
    debugPrint(
      '현재 사용자 ID: $myId, 그룹장 ID: ${_currentGroup.memberId}, 그룹장 여부: $isOwner',
    );

    return isOwner;
  }
}
