// screens/group/group_detail_screen.dart
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
import 'bottomsheet/plan_create_bottom_sheet.dart';
import 'bottomsheet/calendar_event_bottom_sheet.dart';
import 'group_widgets/group_members_bar.dart';
import 'group_widgets/group_edit_dialog.dart';
import '../../models/plan/plan_model.dart';
import '../../providers/user_provider.dart';
import './plan_detail_screen.dart';
import '../../widgets/clover_loading_spinner.dart';
import '../../services/kakao_share_service.dart';
import './group_widgets/group_invitation_dialog.dart';

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
  bool _isLoading = false;
  bool _isMembersBarExpanded = false;

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

  // 멤버바 토글 함수
  void _toggleMembersBar() {
    setState(() {
      _isMembersBarExpanded = !_isMembersBarExpanded;
    });
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

    // Provider의 로딩 상태나 내부 로딩 상태 중 어느 하나라도 로딩 중이면 전체 로딩 표시
    final bool isLoading =
        groupProvider.isLoading ||
        planProvider.isLoading ||
        _isLoadingDetail ||
        _isLoadingPlans;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
      body: LoadingOverlay(
        isLoading:
            _isLoading ||
            groupProvider.isLoading ||
            planProvider.isLoading ||
            _isLoadingDetail ||
            _isLoadingPlans,
        overlayColor: Colors.white.withOpacity(0.7), // 0.7 opacity 유지
        minDisplayTime: const Duration(milliseconds: 1200), // 최소 1.2초 표시
        child: Column(
          children: [
            // 그룹 멤버 바 (수정된 부분)
            if (_groupDetail == null)
              SizedBox(height: 86) // 데이터가 없을 때는 빈 공간만
            else
              GroupMembersBar(
                members: _groupDetail!.members,
                currentUserId: _getMyUserId(),
                isExpanded: _isMembersBarExpanded, // 토글 상태 전달
                onToggle: _toggleMembersBar, // 토글 함수 전달
                onAddMember: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final groupProvider = Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    );

                    // 딥링크 형식으로 초대 URL 생성
                    final inviteUrl = await groupProvider
                        .generateInviteLinkWithDeepLink(_currentGroup.groupId);

                    setState(() {
                      _isLoading = false;
                    });

                    if (inviteUrl != null && mounted) {
                      // 초대 다이얼로그 표시
                      showDialog(
                        context: context,
                        builder:
                            (context) => GroupInvitationDialog(
                              inviteUrl: inviteUrl,
                              expiryDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              onShareKakao: (url) async {
                                // 카카오톡으로 공유
                                final success =
                                    await KakaoShareService.shareGroupInvitation(
                                      groupName: _currentGroup.name,
                                      inviteUrl: url,
                                      description: _currentGroup.description,
                                    );

                                if (!success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('카카오톡 공유에 실패했습니다'),
                                    ),
                                  );
                                }
                              },
                            ),
                      );
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '초대 링크 생성 실패: ${groupProvider.error}',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('초대 링크 생성 중 오류 발생: $e')),
                      );
                    }
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
                  _plans == null
                      ? Container() // 로딩 중에는 빈 컨테이너 (LoadingOverlay에서 처리)
                      : _buildSelectedView(_plans ?? []),
            ),
          ],
        ),
      ),
    );
  }

  // 이하 코드는 그대로 유지

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
  Widget _buildSelectedView(List<PlanList> plans) {
    // 기존 코드 유지
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
                          Navigator.pushNamed(
                            context,
                            '/plan_detail',
                            arguments: {
                              'plan': plan,
                              'groupId': _currentGroup.groupId,
                            },
                          ).then((result) {
                            // 계획에서 나갔다면 해당 계획을 목록에서 즉시 제거
                            if (result != null &&
                                result is Map &&
                                result['action'] == 'leave') {
                              int planId = result['planId'];
                              setState(() {
                                // UI에서 즉시 제거
                                _plans?.removeWhere(
                                  (plan) => plan.planId == planId,
                                );
                              });

                              // 백그라운드에서 계획 목록 다시 로드 (UI는 이미 업데이트됨)
                              _loadPlans();
                            }
                          });
                        },
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

  // 여행 계획 추가 바텀시트
  void _showAddPlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumGray,
                ),
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

    setState(() {
      _isLoading = true; // 로딩 상태 설정
    });

    try {
      final success = await groupProvider.deleteGroup(_currentGroup.groupId);

      if (success) {
        // 그룹 목록 새로고침을 await로 변경
        await Provider.of<GroupProvider>(
          context,
          listen: false,
        ).fetchMyGroups();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('그룹이 삭제되었습니다.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('그룹 삭제 중 오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 상태 해제
        });
      }
    }
  }

  // _getMyUserId 메서드
  int _getMyUserId() {
    // UserProvider에서 현재 로그인한 사용자의 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userProfile != null) {
      try {
        return int.parse(userProvider.userProfile!.userId);
      } catch (e) {
        debugPrint('userId를 정수로 변환하는 중 오류: $e');
      }
    }

    return _currentGroup.memberId;
  }

  bool isGroupOwner() {
    // 현재 로그인한 사용자 ID 가져오기
    final myId = _getMyUserId();

    // 그룹 생성자 ID와 비교
    final isOwner = _currentGroup.memberId == myId;
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
