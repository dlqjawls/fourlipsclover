import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plan/plan_model.dart';
import '../../models/plan/plan_detail_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import '../../widgets/clover_loading_spinner.dart';
import 'plan_widgets/plan_members_bar.dart';
import 'plan_widgets/plan_notice_board.dart';
import 'plan_widgets/timeline_plan_schedule_view.dart';
import 'plan_widgets/plan_settlement_view.dart';
import 'bottomsheet/plan_member_management_sheet.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('계획 상세 정보를 불러오는데 실패했습니다: $e')));
      }
    }
  }

  // 현재 사용자 ID 가져오기
  int _getMyUserId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile != null) {
      try {
        return int.parse(userProvider.userProfile!.userId);
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
    return myUserId == _currentPlan.treasurerId;
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
                      onAddMember: _isUserTreasurer() ? _showMemberManagementSheet : null,
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