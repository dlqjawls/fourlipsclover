// lib/screens/settlement/bottomsheet/settlement/expense_edit_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme.dart';
import '../../../../models/settlement/settlement_model.dart';
import '../../../../models/group/member_model.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../providers/settlement_provider.dart';
import '../../../../widgets/toast_bar.dart';
import '../../plan_widgets/settlement/expense_molbbang_widget.dart';

class ExpenseEditBottomSheet extends StatefulWidget {
  final Expense expense;
  final int planId;
  final int groupId;

  const ExpenseEditBottomSheet({
    Key? key,
    required this.expense,
    required this.planId,
    required this.groupId,
  }) : super(key: key);

  @override
  State<ExpenseEditBottomSheet> createState() => _ExpenseEditBottomSheetState();
}

class _ExpenseEditBottomSheetState extends State<ExpenseEditBottomSheet> {
  late List<ExpenseParticipant> _participants;
  final currencyFormat = NumberFormat('#,###', 'ko_KR');
  List<Member>? _availableMembers;
  bool _isLoading = false;
  late SettlementProvider _settlementProvider;
  ExpenseParticipant? _molbbangParticipant; // 몰빵할 참여자
  bool _showMolbbang = false; // 몰빵 UI 표시 여부

  @override
  void initState() {
    super.initState();
    // 초기 참여자 목록 설정
    _participants = List.from(widget.expense.expenseParticipants);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider 참조를 didChangeDependencies에서 안전하게 가져옴
    _settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    // 사용 가능한 멤버 로드
    _loadAvailableMembers();
  }

  // 사용 가능한 멤버 로드
  Future<void> _loadAvailableMembers() async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    try {
      final planDetail = await planProvider.fetchPlanDetail(
        widget.groupId,
        widget.planId,
      );

      // 현재 참여자를 제외한 멤버 필터링
      final participantMemberIds = _participants.map((p) => p.memberId).toSet();

      if (mounted) {
        setState(() {
          _availableMembers =
              planDetail.members
                  .where(
                    (member) => !participantMemberIds.contains(member.memberId),
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('사용 가능한 멤버 로드 중 오류: $e');
      if (mounted) {
        ToastBar.clover('멤버 정보 로드 실패');
      }
    }
  }

  // 참여자 추가 다이얼로그
  void _showAddParticipantDialog() {
    if (_availableMembers == null || _availableMembers!.isEmpty) {
      ToastBar.clover('추가할 수 있는 멤버가 없습니다.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Member? selectedMember;
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(
                  '참여자 추가',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추가할 멤버를 선택하세요',
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 14,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGray),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<Member>(
                        hint: Text(
                          '멤버 선택',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            color: AppColors.mediumGray,
                          ),
                        ),
                        value: selectedMember,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            _availableMembers!.map((Member member) {
                              return DropdownMenuItem<Member>(
                                value: member,
                                child: Text(
                                  member.nickname,
                                  style: const TextStyle(
                                    fontFamily: 'Anemone_air',
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (Member? newValue) {
                          setState(() {
                            selectedMember = newValue;
                          });
                        },
                      ),
                    ),
                  ],
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
                  ElevatedButton(
                    onPressed:
                        selectedMember != null
                            ? () {
                              // 새 참여자 추가 로직
                              final newParticipant = ExpenseParticipant(
                                expenseParticipantId: 0, // 임시 ID
                                memberId: selectedMember!.memberId,
                                email: selectedMember!.email,
                                nickname: selectedMember!.nickname,
                                profileUrl: selectedMember!.profileUrl,
                              );

                              this.setState(() {
                                _participants.add(newParticipant);

                                // 사용 가능한 멤버 목록에서 제거
                                _availableMembers!.remove(selectedMember);

                                // 몰빵 선택을 초기화
                                _molbbangParticipant = null;
                              });

                              Navigator.of(context).pop();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '추가',
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  // 몰빵 선택 처리
  void _handleMolbbangSelection(int memberId) {
    setState(() {
      // 해당 멤버 찾기
      _molbbangParticipant = _participants.firstWhere(
        (participant) => participant.memberId == memberId,
        orElse: () => _participants.first,
      );
    });
  }

  // 몰빵 취소
  void _cancelMolbbang() {
    setState(() {
      _molbbangParticipant = null;
    });
  }

  // 저장 메서드
  Future<void> _saveParticipants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 참여자 ID 리스트 추출 (몰빵 모드인 경우 해당 참여자만)
      final List<int> memberIds =
          _molbbangParticipant != null
              ? [_molbbangParticipant!.memberId]
              : _participants.map((p) => p.memberId).toList();

      // 로컬 변수에 저장하여 나중에 접근
      final planId = widget.planId;
      final expenseId = widget.expense.expenseId;

      // 참여자 업데이트 API 호출
      final result = await _settlementProvider.updateParticipants(
        expenseId,
        memberIds,
      );

      if (result) {
        // 명시적으로 결제 정보가 있는 planId에 대해 정산 정보 다시 로드
        debugPrint('API 호출 성공, 정산 정보 갱신: planId=$planId');

        // 정산 정보 갱신 - mounted 체크 없이 완료 가능 (Provider에서 알아서 처리)
        await _settlementProvider.fetchSettlementDetail(planId);

        // 성공 메시지
        if (_molbbangParticipant != null) {
          ToastBar.clover('${_molbbangParticipant!.nickname}님에게 몰빵 처리되었습니다!');
        } else {
          ToastBar.clover('참여자가 성공적으로 수정되었습니다.');
        }

        // 바텀시트 닫기 전에 짧은 딜레이 추가
        await Future.delayed(const Duration(milliseconds: 300));

        // mounted 체크 후 Navigator 조작
        if (mounted) {
          Navigator.of(context).pop(true); // 성공 결과 반환
        }
      } else {
        // mounted 체크 후 오류 메시지 표시
        if (mounted) {
          ToastBar.clover('참여자 수정 실패');
        }
      }
    } catch (e) {
      // 에러 처리
      debugPrint('참여자 수정 중 오류 발생: $e');
      // mounted 체크 후 오류 메시지 표시
      if (mounted) {
        ToastBar.clover('참여자 수정 중 오류 발생');
      }
    } finally {
      // mounted 체크 후 로딩 상태 변경
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 인원당 동등 분배 금액 계산
    final perPersonAmount =
        _participants.isEmpty
            ? widget.expense.totalPayment
            : (widget.expense.totalPayment / _participants.length).ceil();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 결제 정보 영수증
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 영수증 상단
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.expense.itemName}',
                              style: const TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'yyyy.MM.dd HH:mm',
                              ).format(widget.expense.approvedAt),
                              style: const TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 점선 구분선 (티켓 절취선 스타일)
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 10).floor(),
                          (index) => Container(
                            width: 5,
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 결제 금액 및 분배 금액 정보
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '총 결제 금액:',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          Text(
                            '${currencyFormat.format(widget.expense.totalPayment)}원',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _molbbangParticipant != null
                                ? '몰빵 처리:'
                                : '1인당 분담금:',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 14,
                              color: AppColors.darkGray,
                            ),
                          ),
                          Text(
                            _molbbangParticipant != null
                                ? '${_molbbangParticipant!.nickname}'
                                : '${currencyFormat.format(perPersonAmount)}원',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  _molbbangParticipant != null
                                      ? Colors.red
                                      : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 탭 선택 (일반 분배 / 몰빵)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.verylightGray,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  // 일반 분배 탭
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => setState(() {
                            _showMolbbang = false;
                            _molbbangParticipant = null;
                          }),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              !_showMolbbang
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '일반 분담',
                          style: TextStyle(
                            color:
                                !_showMolbbang
                                    ? Colors.white
                                    : AppColors.darkGray,
                            fontFamily: 'Anemone_air',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 몰빵 탭
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showMolbbang = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _showMolbbang
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '몰빵하기',
                          style: TextStyle(
                            color:
                                _showMolbbang
                                    ? Colors.white
                                    : AppColors.darkGray,
                            fontFamily: 'Anemone_air',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 주요 내용 (일반 모드 / 몰빵 모드)
          _showMolbbang
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ExpenseMolbbangWidget(
                  participants: _participants,
                  onSelectParticipant: _handleMolbbangSelection,
                  selectedParticipant: _molbbangParticipant,
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 참여자 목록 타이틀 및 추가 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '참여자 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Anemone_air',
                            color: AppColors.darkGray,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddParticipantDialog,
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('추가'),
                          style: ElevatedButton.styleFrom(
                            iconColor: AppColors.background,
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 참여자 목록 - 그리드 형태
                    _participants.isEmpty
                        ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.verylightGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '참여자가 없습니다.\n멤버를 추가해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              color: AppColors.mediumGray,
                            ),
                          ),
                        )
                        : Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: _participants.length,
                            itemBuilder: (context, index) {
                              final participant = _participants[index];
                              return _buildParticipantCard(participant, index);
                            },
                          ),
                        ),
                  ],
                ),
              ),

          // 저장 버튼 (취소 버튼 없이 크게 표시)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed:
                          (_participants.isEmpty &&
                                  _molbbangParticipant == null)
                              ? null
                              : _saveParticipants,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _molbbangParticipant != null ? '몰빵 저장' : '참여자 저장',
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // 참여자 카드 위젯
  Widget _buildParticipantCard(ExpenseParticipant participant, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            backgroundImage:
                participant.profileUrl != null
                    ? NetworkImage(participant.profileUrl!)
                    : null,
            child:
                participant.profileUrl == null
                    ? Text(
                      participant.nickname.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),

          const SizedBox(width: 8),

          // 닉네임
          Expanded(
            child: Text(
              participant.nickname,
              style: const TextStyle(fontFamily: 'Anemone_air', fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 삭제 버튼
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade500, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed:
                _participants.length > 1
                    ? () {
                      setState(() {
                        final removedMember = Member(
                          memberId: participant.memberId,
                          email: participant.email,
                          nickname: participant.nickname,
                          profileUrl: participant.profileUrl,
                        );

                        // 참여자 제거
                        _participants.removeAt(index);

                        // 가능한 멤버 목록에 추가
                        if (_availableMembers != null) {
                          _availableMembers!.add(removedMember);
                        }
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
