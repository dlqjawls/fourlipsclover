import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../models/group/member_model.dart';
import '../../../../models/plan/member_info_response.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../widgets/clover_loading_spinner.dart';
import '../../../../widgets/toast_bar.dart';
import 'train_seat_member_selection.dart';

class PlanMemberManagementSheet extends StatefulWidget {
  final int planId;
  final int groupId;
  final List<Member> currentMembers; // 현재 계획에 속한 멤버들

  const PlanMemberManagementSheet({
    Key? key,
    required this.planId,
    required this.groupId,
    required this.currentMembers,
  }) : super(key: key);

  @override
  State<PlanMemberManagementSheet> createState() =>
      _PlanMemberManagementSheetState();
}

class _PlanMemberManagementSheetState extends State<PlanMemberManagementSheet> {
  bool _isLoading = false;
  int _currentStep = 0; // 0: 추가 가능한 멤버 조회 중, 1: 멤버 선택
  List<MemberInfoResponse>? _availableMembers;
  Set<int> _selectedMemberIds = {};
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchAvailableMembers();
  }

  // 추가 가능한 멤버 목록 조회
  Future<void> _fetchAvailableMembers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final members = await planProvider.fetchAvailableMembers(
        widget.groupId,
        widget.planId,
      );

      if (mounted) {
        setState(() {
          _availableMembers = members;
          _isLoading = false;
          _currentStep = members.isEmpty ? 0 : 1; // 추가 가능한 멤버가 없으면 0단계 유지
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = '멤버 목록을 불러오는데 실패했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 선택한 멤버 추가하기
  Future<void> _addSelectedMembers() async {
    if (_selectedMemberIds.isEmpty) {
      // 선택된 멤버가 없으면 추가하지 않음
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      await planProvider.addMembersToPlan(
        widget.groupId,
        widget.planId,
        _selectedMemberIds.toList(),
      );

      if (mounted) {
        ToastBar.clover('${_selectedMemberIds.length}명의 멤버가 추가되었습니다.');
        Navigator.of(context).pop(true); // 변경 사항이 있음을 알림
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = '멤버 추가에 실패했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userProfile?.memberId;
    int? parsedUserId = currentUserId;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Container(
        padding: const EdgeInsets.only(top: 8.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 바 및 제목
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    '여행 멤버 추가',
                    style: TextStyle(
                      fontFamily: 'Anemone',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  // 추가 버튼 (멤버 선택 단계에서만 활성화)
                  TextButton(
                    onPressed: _currentStep == 1 ? _addSelectedMembers : null,
                    child: Text(
                      '추가',
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        color:
                            _currentStep == 1
                                ? AppColors.primary
                                : AppColors.mediumGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 구분선
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),

            // 에러 메시지
            if (_errorMsg != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.red.withOpacity(0.1),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                    fontFamily: 'Anemone_air',
                    color: Colors.red,
                  ),
                ),
              ),

            // 메인 컨텐츠
            if (_availableMembers == null || _availableMembers!.isEmpty)
              _buildEmptyState()
            else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    // 선택된 멤버 수 표시
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '선택된 멤버: ${_selectedMemberIds.length}명',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 멤버 선택 UI
                    Expanded(child: _buildMemberSelection(parsedUserId)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 추가 가능한 멤버가 없는 경우 표시할 빈 상태
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 64, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Text(
            '추가할 수 있는 멤버가 없습니다',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '그룹에 속한 모든 멤버가 이미 계획에 참여하고 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'Anemone_air',
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 기차 좌석 UI를 사용한 멤버 선택 위젯
  Widget _buildMemberSelection(int? currentUserId) {
    // MemberInfoResponse를 Member로 변환
    final members =
        _availableMembers!.map((info) {
          return Member(
            memberId: info.memberId,
            email: info.email,
            nickname: info.nickname,
          );
        }).toList();

    return TrainSeatMemberSelection(
      members: members,
      selectedMemberIds: _selectedMemberIds,
      currentUserId: currentUserId,
      onMemberSelected: (memberId, isSelected) {
        setState(() {
          if (isSelected) {
            _selectedMemberIds.add(memberId);
          } else {
            _selectedMemberIds.remove(memberId);
          }
        });
      },
    );
  }
}
