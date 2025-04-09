import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group/group_model.dart';
import '../../models/plan/plan_model.dart';
import '../../models/plan/plan_detail_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import '../../widgets/clover_loading_spinner.dart';
import '../../widgets/toast_bar.dart';
import 'plan_widgets/plan_members_bar.dart';
import 'plan_widgets/plan_notice_board.dart';
import 'plan_widgets/timeline_plan_schedule_view.dart';
import 'plan_widgets/plan_settlement_view.dart';
import 'bottomsheet/plan_member_management_sheet.dart';
import '../../config/theme.dart';

class PlanDetailScreen extends StatefulWidget {
  final Plan plan;
  final int groupId;
  final int initialTabIndex; // 초기 선택 탭 인덱스 추가

  const PlanDetailScreen({
    Key? key,
    required this.plan,
    required this.groupId,
    this.initialTabIndex = 0, // 기본값은 0(공지사항 탭)
  }) : super(key: key);

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late int _selectedIndex; // 0: 공지사항, 1: 여행 상세 계획, 2: 정산
  late Plan _currentPlan;
  PlanDetail? _planDetail;
  bool _isLoading = false;
  bool _isMembersBarExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _selectedIndex = widget.initialTabIndex; // 초기 탭 인덱스 설정

    // 빌드가 완료된 후 계획 상세 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlanDetail();
    });
  }

  // 멤버바 토글 함수
  void _toggleMembersBar() {
    setState(() {
      _isMembersBarExpanded = !_isMembersBarExpanded;
    });
  }

  // 계획 상세 정보 로드
  Future<void> _loadPlanDetail() async {
    setState(() {
      _isLoading = true;
    });

    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    try {
      final detail = await planProvider.fetchPlanDetail(
        widget.groupId,
        _currentPlan.planId,
      );

      if (mounted) {
        setState(() {
          _planDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('계획 상세 정보 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // 오류 메시지 표시
        ToastBar.clover('계획 상세정보 불러오기 실패');
      }
    }
  }

  // 현재 사용자 ID 가져오기
  int _getMyUserId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile != null) {
      try {
        return userProvider.userProfile!.memberId;
      } catch (e) {
        debugPrint('userId를 정수로 변환하는 중 오류: $e');
      }
    }
    return 0; // 기본값
  }

  // 멤버 관리 바텀시트 표시
  void _showMemberManagementSheet() {
    if (_planDetail == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면 크기로 확장 가능
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PlanMemberManagementSheet(
          planId: _currentPlan.planId,
          groupId: widget.groupId,
          currentMembers: _planDetail!.members,
        );
      },
    ).then((memberAdded) {
      // 멤버가 추가되었다면 상세 정보 다시 로드
      if (memberAdded == true) {
        _loadPlanDetail();
      }
    });
  }

  // 사용자가 총무인지 확인
  bool _isUserTreasurer() {
    final myUserId = _getMyUserId();
    return myUserId == _planDetail?.treasurerId;
  }

  // 총무 위임 다이얼로그
  void _showTransferTreasurerDialog() {
    if (_planDetail == null) return;

    final myUserId = _getMyUserId();
    // 다른 멤버들 (현재 사용자 제외)
    final otherMembers =
        _planDetail!.members
            .where((member) => member.memberId != myUserId)
            .toList();

    if (otherMembers.isEmpty) {
      ToastBar.clover('다른 멤버가 없어 총무권한 이전 실패');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('총무 위임'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: otherMembers.length,
              itemBuilder: (context, index) {
                final member = otherMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        member.profileUrl != null
                            ? NetworkImage(member.profileUrl!)
                            : null,
                    child:
                        member.profileUrl == null
                            ? Text(member.nickname.substring(0, 1))
                            : null,
                  ),
                  title: Text(member.nickname),
                  onTap: () {
                    Navigator.of(context).pop();
                    _transferTreasurer(member.memberId.toInt());
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // 취소 버튼은 회색으로
              ),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  // 총무 위임 실행
  Future<void> _transferTreasurer(int newTreasurerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);

      await planProvider.editTreasurer(
        groupId: widget.groupId,
        planId: _currentPlan.planId,
        newTreasurerId: newTreasurerId,
      );

      // 성공 메시지 표시
      if (mounted) {
        ToastBar.clover('총무 권한 이전 완료');

        // 계획 정보 다시 로드
        _loadPlanDetail();
      }
    } catch (e) {
      if (mounted) {
        ToastBar.clover('총무 권한 이전 실패');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 계획 나가기 확인 다이얼로그
  void _showLeavePlanDialog() {
    final myUserId = _getMyUserId();
    final isTreasurer = myUserId == _planDetail?.treasurerId;
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final memberCount = planProvider.getPlanMemberCount(_currentPlan.planId);

    String message;

    if (isTreasurer && memberCount > 1) {
      // 총무이고 다른 멤버가 있는 경우
      message = '총무는 먼저 권한을 다른 멤버에게 넘긴 후 계획에서 나갈 수 있습니다. 총무 권한을 넘기시겠습니까?';
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('권한 이전 필요'),
            content: Text(message),
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
                  _showTransferTreasurerDialog();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('권한 넘기기'),
              ),
            ],
          );
        },
      );
    } else {
      // 일반 멤버이거나 총무이지만 혼자인 경우
      message =
          isTreasurer && memberCount == 1
              ? '당신은 이 계획의. 마지막 멤버입니다. 나가시면 계획이 삭제됩니다. 정말 나가시겠습니까?'
              : '계획에서 나가시겠습니까? 이 작업은 취소할 수 없습니다.';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('계획 나가기'),
            content: Text(message),
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
                  _leavePlan();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('나가기'),
              ),
            ],
          );
        },
      );
    }
  }

  // 계획 나가기 실행
  Future<void> _leavePlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      await planProvider.leavePlan(widget.groupId, _currentPlan.planId);

      // 계획 화면 종료하고 그룹 상세 화면으로 돌아가기
      if (mounted) {
        ToastBar.clover('계획에서 나갔습니다.');

        // groupId를 사용하여 다시 Group 객체 가져오기
        Group? group;
        try {
          group = groupProvider.groups.firstWhere(
            (g) => g.groupId == widget.groupId,
          );
        } catch (e) {
          // 그룹을 찾지 못한 경우
          group = null;
        }

        if (group != null) {
          // 모든 이전 화면을 제거하고 GroupDetailScreen 다시 로드
          Navigator.of(
            context,
          ).pushReplacementNamed('/group_detail', arguments: {'group': group});
        } else {
          // 그룹을 찾을 수 없으면 그냥 이전 화면으로 돌아감
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastBar.clover('계획 나가기 실패');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final isProviderLoading = planProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          _currentPlan.title,
          style: TextStyle(
            fontFamily: 'Anemone',
            fontSize: 30,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 더보기 메뉴 추가
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'transfer_treasurer') {
                _showTransferTreasurerDialog();
              } else if (value == 'leave_plan') {
                _showLeavePlanDialog();
              }
            },
            itemBuilder: (context) {
              final myUserId = _getMyUserId();
              final isTreasurer = myUserId == _planDetail?.treasurerId;

              // 총무인 경우와 아닌 경우 메뉴 아이템을 다르게 구성
              List<PopupMenuItem<String>> items = [];

              if (isTreasurer) {
                // 총무인 경우 '총무 위임' 메뉴 추가
                items.add(
                  const PopupMenuItem<String>(
                    value: 'transfer_treasurer',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('총무 위임'),
                      ],
                    ),
                  ),
                );
              }

              // 모든 사용자에게 '계획 나가기' 메뉴 표시
              items.add(
                PopupMenuItem<String>(
                  value: 'leave_plan',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text('계획 나가기', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              );

              return items;
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || isProviderLoading,
        overlayColor: Colors.white.withOpacity(0.7),
        minDisplayTime: const Duration(milliseconds: 1200),
        child:
            _planDetail == null
                ? Container() // 데이터가 없는 경우 빈 컨테이너 (로딩 스피너가 대신 표시됨)
                : Column(
                  children: [
                    // 여행 멤버 바
                    PlanMembersBar(
                      members: _planDetail!.members,
                      currentUserId: _getMyUserId(),
                      treasurerId: _planDetail!.treasurerId,
                      isExpanded: _isMembersBarExpanded,
                      onToggle: _toggleMembersBar,
                      // 총무만 멤버 추가 가능하도록 설정
                      onAddMember:
                          _isUserTreasurer()
                              ? _showMemberManagementSheet
                              : null,
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
                          _buildTabButton('공지사항', 0, Icons.announcement),
                          _buildTabButton('상세 일정', 1, Icons.schedule),
                          _buildTabButton('정산', 2, Icons.receipt_long),
                        ],
                      ),
                    ),

                    // 선택된 탭에 따른 컨텐츠
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _buildSelectedView(),
                      ),
                    ),
                  ],
                ),
      ),
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
  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 0: // 공지사항
        return PlanNoticeBoard(
          planId: _currentPlan.planId,
          groupId: widget.groupId,
        );

      case 1: // 여행 상세 계획
        return TimelinePlanScheduleView(
          plan: _currentPlan,
          groupId: widget.groupId,
        );

      case 2: // 정산
        return PlanSettlementView(
          planId: _currentPlan.planId,
          groupId: widget.groupId,
          members: _planDetail?.members ?? [],
          planTitle: _currentPlan.title,
        );

      default:
        return Container();
    }
  }
}
