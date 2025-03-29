import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_create_request.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/group_provider.dart';
import '../../../models/group/member_model.dart';
import '../../../config/theme.dart';
import './plan_date_selection.dart';
import './train_seat_member_selection.dart';
import './plan_info_input.dart';

class PlanCreateBottomSheet extends StatefulWidget {
  final int groupId;

  const PlanCreateBottomSheet({Key? key, required this.groupId})
    : super(key: key);

  @override
  State<PlanCreateBottomSheet> createState() => _PlanCreateBottomSheetState();
}

class _PlanCreateBottomSheetState extends State<PlanCreateBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 단계 관리
  int _currentStep = 0; // 0: 날짜 선택, 1: 멤버 선택, 2: 제목/설명 입력

  // 날짜 선택
  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;

  // 그룹 멤버 목록
  List<Member>? _groupMembers;

  // 여행에 참여할 멤버 ID 목록
  final Set<int> _selectedMemberIds = {};

  bool _isTitleEmpty = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 바텀시트 초기화시 그룹 멤버 목록 가져오기
    _fetchGroupMembers();
  }

  // 그룹 멤버 목록 가져오기
  Future<void> _fetchGroupMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupDetail = await Provider.of<GroupProvider>(
        context,
        listen: false,
      ).fetchGroupDetail(widget.groupId);

      if (groupDetail != null) {
        setState(() {
          _groupMembers = groupDetail.members;

          // 모든 멤버를 기본으로 선택
          for (var member in groupDetail.members) {
            _selectedMemberIds.add(member.memberId);
          }
        });
      }
    } catch (e) {
      debugPrint('그룹 멤버 목록을 가져오는데 실패했습니다: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('멤버 목록을 가져오는데 실패했습니다: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 날짜 선택 콜백
  void _handleDatesSelected(DateTime? start, DateTime? end, DateTime focused) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _focusedDay = focused;
    });
  }

  // 다음 단계로 이동
  void _nextStep() {
    // 현재 단계에 따른 유효성 검사
    if (_currentStep == 0) {
      // 날짜 선택 단계: 시작일과 종료일이 모두 선택되었는지 확인
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행 시작일과 종료일을 모두 선택해주세요')));
        return;
      }
    } else if (_currentStep == 1) {
      // 멤버 선택 단계: 최소 한 명 이상의 멤버가 선택되었는지 확인
      if (_selectedMemberIds.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('최소 한 명 이상의 멤버를 선택해주세요')));
        return;
      }
    }

    // 다음 단계로 이동
    setState(() {
      _currentStep++;
    });
  }

  // 이전 단계로 이동
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userProfile?.userId;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 키보드가 올라왔을 때 시트 높이를 증가시키지만, 더 적절한 값으로 조정
    final sheetHeight =
        keyboardHeight > 0
            ? screenHeight *
                0.9 // 키보드가 표시될 때 더 적절한 높이
            : screenHeight * 0.75; // 원래 높이

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 0, right: 0),
      // 최대 높이만 설정하고 bottom padding은 제거
      constraints: BoxConstraints(maxHeight: sheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 상단 제목 (가운데 정렬)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _getStepTitle(),
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 내용 영역 - SingleChildScrollView 제거
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCurrentStepContent(),
          ),

          // 하단 버튼 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이전 버튼 (첫 단계에서는 취소 버튼)
                TextButton(
                  onPressed:
                      _currentStep == 0
                          ? () => Navigator.of(context).pop()
                          : _previousStep,
                  child: Text(
                    _currentStep == 0 ? '취소' : '이전',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),

                // 다음 또는 생성 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      currentUserId == null || _isLoading
                          ? null
                          : (_currentStep < 2
                              ? _nextStep
                              : () => _createPlan(int.parse(currentUserId))),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            _currentStep < 2 ? '다음' : '생성',
                            style: const TextStyle(
                              fontFamily: 'Anemone_air',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 현재 단계 제목 가져오기
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return '여행 날짜';
      case 1:
        return '여행 열차';
      case 2:
        return '여행 정보';
      default:
        return '새 여행 계획 만들기';
    }
  }

  // 현재 단계에 따른 내용 위젯 반환
  Widget _buildCurrentStepContent() {
    try {
      switch (_currentStep) {
        case 0:
          // 날짜 선택 페이지 - 스크롤 없음
          return PlanDateSelection(
            startDate: _startDate,
            endDate: _endDate,
            focusedDay: _focusedDay,
            onDatesSelected: _handleDatesSelected,
          );
        case 1:
          // 멤버 선택 페이지 - 스크롤 없음
          return _buildMemberSelectionStep();
        case 2:
          // 정보 입력 페이지 - 이미 SingleChildScrollView를 내부에 포함하고 있음
          return _startDate != null && _endDate != null
              ? PlanInfoInput(
                startDate: _startDate!,
                endDate: _endDate!,
                selectedMemberCount: _selectedMemberIds.length,
                titleController: _titleController,
                descriptionController: _descriptionController,
                isTitleEmpty: _isTitleEmpty,
              )
              : const Center(child: Text('날짜를 먼저 선택해주세요'));
        default:
          return const SizedBox.shrink();
      }
    } catch (e, stackTrace) {
      debugPrint('_buildCurrentStepContent 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');

      // 오류 발생 시 기본 UI 반환
      return Center(
        child: Text(
          '화면을 불러오는 데 실패했습니다: $e',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  // 멤버 선택 단계 - 기차 좌석 UI 사용
  Widget _buildMemberSelectionStep() {
    // 현재 로그인한 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userProfile?.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 멤버 수 표시
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: AppColors.primary, size: 20),
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

        // 기차 좌석 UI
        Expanded(
          child:
              _groupMembers == null || _groupMembers!.isEmpty
                  ? Center(
                    child: Text(
                      '그룹 멤버가 없습니다.',
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 16,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  )
                  : TrainSeatMemberSelection(
                    members: _groupMembers!,
                    selectedMemberIds: _selectedMemberIds,
                    currentUserId:
                        currentUserId != null ? int.parse(currentUserId) : null,
                    onMemberSelected: (memberId, isSelected) {
                      setState(() {
                        if (isSelected) {
                          _selectedMemberIds.add(memberId);
                        } else {
                          _selectedMemberIds.remove(memberId);
                        }
                      });
                    },
                  ),
        ),
      ],
    );
  }

  // 계획 생성하기
  Future<void> _createPlan(int currentUserId) async {
    final title = _titleController.text.trim();

    // 제목 검증
    if (title.isEmpty) {
      setState(() {
        _isTitleEmpty = true;
      });
      return;
    }

    // 종료일 검증
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('종료일은 시작일 이후로 설정해주세요')));
      return;
    }

    // 여행 멤버 선택 검증
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('최소 한 명 이상의 멤버를 선택해주세요')));
      return;
    }

    // 계획 생성 직전에 디버그 출력
    debugPrint('요청에 사용될 treasurerId: $currentUserId');
    debugPrint('selectedMemberIds: $_selectedMemberIds');

    // 로딩 상태 설정
    setState(() {
      _isLoading = true;
    });

    try {
      // Provider의 createPlan 메서드 사용
      final planProvider = Provider.of<PlanProvider>(context, listen: false);

      // 계획 생성 요청 객체 생성
      final request = PlanCreateRequest(
        title: title,
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        members: _selectedMemberIds.toList(),
        treasurerId: currentUserId, // 현재 사용자를 총무로 설정
      );

      // API 호출하여 계획 생성
      await planProvider.createPlan(groupId: widget.groupId, request: request);

      // 성공 시 바텀시트 닫기
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행 계획이 성공적으로 생성되었습니다!')));
        Navigator.of(context).pop(true); // true 반환하여 생성 성공 알림
      }
    } catch (e) {
      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('계획 생성에 실패했습니다: $e')));
      }
    } finally {
      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
