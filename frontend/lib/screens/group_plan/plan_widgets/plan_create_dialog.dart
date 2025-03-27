import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_create_request.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/group_provider.dart';
import '../../../models/group/group_detail_model.dart';
import '../../../models/group/member_model.dart';

class PlanCreateDialog extends StatefulWidget {
  final int groupId;

  const PlanCreateDialog({Key? key, required this.groupId}) : super(key: key);

  @override
  State<PlanCreateDialog> createState() => _PlanCreateDialogState();
}

class _PlanCreateDialogState extends State<PlanCreateDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isTitleEmpty = false;
  bool _isLoading = false;
  
  // 그룹 멤버 목록
  List<Member>? _groupMembers;
  
  // 여행에 참여할 멤버 ID 목록
  final Set<int> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();
    // 다이얼로그 초기화시 그룹 멤버 목록 가져오기
    _fetchGroupMembers();
  }

  // 그룹 멤버 목록 가져오기
  Future<void> _fetchGroupMembers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final groupDetail = await Provider.of<GroupProvider>(context, listen: false)
          .fetchGroupDetail(widget.groupId);
      
      if (groupDetail != null) {
        setState(() {
          _groupMembers = groupDetail.members;
          
          // 현재 로그인한 사용자를 기본으로 선택
          final currentUserId = Provider.of<UserProvider>(context, listen: false).userProfile?.userId;
          if (currentUserId != null) {
            _selectedMemberIds.add(int.parse(currentUserId));
          }
        });
      }
    } catch (e) {
      debugPrint('그룹 멤버 목록을 가져오는데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('멤버 목록을 가져오는데 실패했습니다: $e')),
      );
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

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 정보 가져오기
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userProfile?.userId;
    
    return AlertDialog(
      title: Text(
        '새 여행 계획 만들기',
        style: TextStyle(
          fontFamily: 'Anemone_air',
          color: AppColors.darkGray,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontFamily: 'Anemone_air'),
                    decoration: InputDecoration(
                      labelText: '여행 제목',
                      hintText: '여행 제목을 입력하세요',
                      errorText: _isTitleEmpty ? '제목을 입력해주세요' : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),

                  // 설명 입력
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(fontFamily: 'Anemone_air'),
                    decoration: InputDecoration(
                      labelText: '여행 설명',
                      hintText: '여행에 대한 설명을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // 날짜 선택 컨테이너
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '여행 기간',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 날짜 선택 - 시작일
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '시작일',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy년 MM월 dd일').format(_startDate),
                                  style: const TextStyle(fontFamily: 'Anemone_air'),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 날짜 선택 - 종료일
                        InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '종료일',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy년 MM월 dd일').format(_endDate),
                                  style: const TextStyle(fontFamily: 'Anemone_air'),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 여행 참여 멤버 선택
                  if (_groupMembers != null && _groupMembers!.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '여행 참여 멤버',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // 멤버 선택 체크박스 목록
                          ...(_groupMembers ?? []).map((member) {
                            // 현재 사용자가 기본 선택되어 있고 비활성화 (무조건 포함)
                            final isCurrentUser = member.memberId == currentUserId;
                            
                            return CheckboxListTile(
                              title: Text(
                                '${member.nickname}${isCurrentUser ? ' (나)' : ''}',
                                style: const TextStyle(fontFamily: 'Anemone_air'),
                              ),
                              value: _selectedMemberIds.contains(member.memberId) || isCurrentUser,
                              onChanged: isCurrentUser 
                                  ? null  // 현재 사용자는 변경 불가
                                  : (selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedMemberIds.add(member.memberId);
                                        } else {
                                          _selectedMemberIds.remove(member.memberId);
                                        }
                                      });
                                    },
                              activeColor: AppColors.primary,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              color: AppColors.mediumGray,
            ),
          ),
        ),
        // 여행 계획 생성 버튼
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: currentUserId == null || _isLoading ? null : () => _createPlan(int.parse(currentUserId)),
          child: _isLoading 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  '생성',
                  style: TextStyle(fontFamily: 'Anemone_air', color: Colors.white),
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
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료일은 시작일 이후로 설정해주세요')),
      );
      return;
    }
    
    // 여행 멤버 선택 검증
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 한 명 이상의 멤버를 선택해주세요')),
      );
      return;
    }

        // 계획 생성 직전에 다음 코드를 추가
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
        startDate: _startDate,
        endDate: _endDate,
        members: _selectedMemberIds.toList(),
        treasurerId: currentUserId, // 현재 사용자를 총무로 설정
      );

      // API 호출하여 계획 생성
      await planProvider.createPlan(
        groupId: widget.groupId,
        request: request,
      );

      // 성공 시 다이얼로그 닫기
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 계획이 성공적으로 생성되었습니다!')),
        );
        Navigator.of(context).pop(true); // true 반환하여 생성 성공 알림
      }
    } catch (e) {
      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계획 생성에 실패했습니다: $e')),
        );
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

  // 날짜 선택 다이얼로그 표시
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate =
        isStartDate ? DateTime.now() : _startDate; // 종료일은 시작일 이후로만 선택 가능

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // 시작일이 종료일보다 나중이면 종료일도 함께 조정
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }
}