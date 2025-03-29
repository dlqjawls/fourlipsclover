// screens/group/group_detail_screen.dartloading
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/group/group_model.dart';
import '../../models/group/group_detail_model.dart';
import '../../models/plan/plan_list_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/group_provider.dart';
import '../../config/theme.dart';
import 'group_widgets/group_calendar.dart';
import 'plan_widgets/empty_plan_view.dart';
import 'plan_widgets/plan_list_view.dart';
import 'plan_widgets/plan_create_bottom_sheet.dart';
import 'group_widgets/calendar_event_bottom_sheet.dart';
import 'group_widgets/group_members_bar.dart';
import 'group_widgets/group_edit_dialog.dart';
import '../../models/plan/plan_model.dart';
import '../../providers/user_provider.dart';

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

  // 그룹의 여행 계획 목록
  List<PlanList>? _plans;
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;

    // 빌드가 완료된 후 그룹 상세 정보 및 계획 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupDetail();
      _loadPlans();
    });
  }

  // 그룹 상세 정보 로드
  Future<void> _loadGroupDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    try {
      final detail = await groupProvider.fetchGroupDetail(
        _currentGroup.groupId,
      );

      if (mounted && detail != null) {
        // detail이 null이 아닌지 확인
        // 역할 설정 로직
        _setMemberRoles(detail);

        setState(() {
          _groupDetail = detail;
          _isLoadingDetail = false;
        });
      } else {
        // detail이 null인 경우 처리
        if (mounted) {
          setState(() {
            _isLoadingDetail = false;
          });
          // 선택적으로 사용자에게 오류 메시지 표시
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('그룹 상세 정보를 불러오는데 실패했습니다.')));
        }
      }
    } catch (e) {
      debugPrint('그룹 상세 정보 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  // GroupDetail 타입을 명시적으로 지정
  void _setMemberRoles(GroupDetail detail) {
    // 그룹장(OWNER) 설정 - 그룹 생성자
    for (var member in detail.members) {
      if (member.memberId == _currentGroup.memberId) {
        member.role = 'OWNER';
      } else {
        member.role = 'MEMBER'; // 나머지는 모두 일반 멤버
      }
    }
  }

  // 여행 계획 목록 로드
  Future<void> _loadPlans() async {
    setState(() {
      _isLoadingPlans = true;
    });

    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    try {
      final plans = await planProvider.fetchPlans(_currentGroup.groupId);

      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoadingPlans = false;
        });
      }
    } catch (e) {
      debugPrint('계획 목록 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingPlans = false;
        });
      }
    }
  }

  // 총무 이름 맵 생성 메서드
  Map<int, String> _getTreasurerNames(List<PlanList> plans) {
    final Map<int, String> result = {};
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    for (var plan in plans) {
      // 여기서는 실제 데이터를 가져오는 메서드 호출
      // 예시: 총무 이름을 가져오는 API 호출 또는 로컬 데이터 사용
      String treasurerName = '총무'; // 기본값

      // 멤버 목록에서 총무 ID에 해당하는 이름 찾기
      if (_groupDetail != null) {
        for (var member in _groupDetail!.members) {
          if (member.memberId == plan.treasurerId) {
            treasurerName = member.nickname;
            break;
          }
        }
      }

      result[plan.planId] = treasurerName;
    }

    return result;
  }

  // 멤버 수 맵 생성 메서드
  Map<int, int> _getMemberCounts(List<PlanList> plans) {
    final Map<int, int> result = {};
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    for (var plan in plans) {
      // 여기서는 실제 데이터를 가져오는 메서드 호출
      // 멤버 수를 계산하는 로직 - API 호출 또는 로컬 데이터 사용
      int memberCount = 0;

      // 예: 플랜 상세 정보로부터 멤버 수 계산
      // 실제 구현은 데이터 소스에 따라 달라질 수 있음
      try {
        // 예시) planProvider를 통해 계획의 멤버 수를 가져옴
        memberCount = planProvider.getPlanMemberCount(plan.planId);
      } catch (e) {
        debugPrint('멤버 수 계산 중 오류: $e');
        // 기본값으로 1 설정 (최소한 총무는 있으므로)
        memberCount = 1;
      }

      result[plan.planId] = memberCount;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

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
                  Expanded(
                    child:
                        _isLoadingPlans && _plans == null
                            ? const Center(child: CircularProgressIndicator())
                            : _buildSelectedView(_plans ?? []),
                  ),
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

  // 선택된 탭에 따른 컨텐츠 빌드
  Widget _buildSelectedView(List<PlanList> plans) {
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
            // 이벤트 로더 수정: FutureBuilder와 함께 캐싱을 활용하는 방식으로 변경됨
            eventLoader: (day) {
              // GroupCalendar 내부에서 처리되므로 여기서는 빈 배열 반환
              return [];
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
                      onTap: () => _showAddPlanBottomSheet(),
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
                      ? EmptyPlanView(
                        onAddPlan: () => _showAddPlanBottomSheet(),
                      )
                      : PlanListView(
                        plans: plans.map(_convertPlanListToPlan).toList(),
                        onPlanSelected: (plan) {
                          // 여행 상세 화면으로 이동
                          Navigator.pushNamed(
                            context,
                            '/plan_detail',
                            arguments: {
                              'plan': plan,
                              'groupId': _currentGroup.groupId,
                            },
                          );
                        },
                        // treasurerNames와 memberCounts 추가
                        treasurerNames: _getTreasurerNames(plans),
                        memberCounts: _getMemberCounts(plans),
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

  // 캘린더 이벤트 바텀시트 표시
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

  // 여행 계획 추가 바텀시트트
  void _showAddPlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라왔을 때 바텀시트가 올라가도록 설정
      backgroundColor: Colors.transparent, // 투명 배경 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => PlanCreateBottomSheet(groupId: _currentGroup.groupId),
    ).then((result) {
      // 바텀시트가 닫힌 후 결과에 따라 계획 목록 다시 로드
      if (result == true) {
        _loadPlans();
      }
    });
  }

  // 그룹 정보 수정 다이얼로그 표시
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

  // _getMyUserId 메서드 수정
  int _getMyUserId() {
    // UserProvider에서 현재 로그인한 사용자의 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userProfile != null) {
      // UserProfile에서 userId를 정수로 변환하여 반환
      try {
        // userId 문자열을 정수로 변환
        return int.parse(userProvider.userProfile!.userId);
      } catch (e) {
        debugPrint('userId를 정수로 변환하는 중 오류: $e');
      }
    }

    // UserProvider에서 값을 가져올 수 없거나 변환할 수 없는 경우,
    // _currentGroup.memberId 값을 반환 (그룹 생성자가 현재 로그인한 사용자일 가능성이 높음)
    return _currentGroup.memberId;
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

  Plan _convertPlanListToPlan(PlanList planList) {
    return Plan(
      planId: planList.planId,
      groupId: planList.groupId,
      treasurerId: planList.treasurerId,
      title: planList.title,
      description: planList.description,
      startDate: planList.startDate,
      endDate: planList.endDate,
      createdAt: planList.createdAt,
      updatedAt: null,
    );
  }
}
