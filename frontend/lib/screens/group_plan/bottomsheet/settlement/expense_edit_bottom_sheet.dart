import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme.dart';
import '../../../../models/settlement/settlement_model.dart';
import '../../../../models/group/member_model.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../providers/settlement_provider.dart';
import '../../../../widgets/toast_bar.dart';

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
  late Map<int, double> _participantRatios;
  final currencyFormat = NumberFormat('#,###', 'ko_KR');
  List<Member>? _availableMembers;
  bool _isLoading = false;
  late SettlementProvider _settlementProvider;

  @override
  void initState() {
    super.initState();
    // 초기 참여자 목록과 비율 설정 (기본 N분의 1)
    _participants = List.from(widget.expense.expenseParticipants);
    _participantRatios = {
      for (var participant in _participants)
        participant.memberId: 1.0 / _participants.length,
    };
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider 참조를 didChangeDependencies에서 안전하게 가져옴
    _settlementProvider = Provider.of<SettlementProvider>(context, listen: false);
    
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

  // 참여자 비율 계산
  void _updateParticipantRatios() {
    final totalRatio = _participantRatios.values.reduce((a, b) => a + b);

    // 비율이 1을 초과하거나 미달하는 경우 조정
    if (totalRatio != 1.0) {
      _participantRatios = {
        for (var memberId in _participantRatios.keys)
          memberId: _participantRatios[memberId]! / totalRatio,
      };
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
                title: const Text('참여자 추가'),
                content: DropdownButton<Member>(
                  hint: const Text('멤버 선택'),
                  value: selectedMember,
                  items:
                      _availableMembers!.map((Member member) {
                        return DropdownMenuItem<Member>(
                          value: member,
                          child: Text(member.nickname),
                        );
                      }).toList(),
                  onChanged: (Member? newValue) {
                    setState(() {
                      selectedMember = newValue;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
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
                                // 새 참여자의 초기 비율 설정 (균등 분배)
                                _participantRatios[newParticipant.memberId] =
                                    1.0 / _participants.length;
                                _updateParticipantRatios();

                                // 사용 가능한 멤버 목록에서 제거
                                _availableMembers!.remove(selectedMember);
                              });

                              Navigator.of(context).pop();
                            }
                            : null,
                    child: const Text('추가'),
                  ),
                ],
              ),
        );
      },
    );
  }

  // 저장 메서드 (오류 수정 버전)
  Future<void> _saveParticipants() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 참여자 ID 리스트 추출
      final memberIds = _participants.map((p) => p.memberId).toList();
      
      // 로컬 변수에 저장하여 나중에 접근
      final planId = widget.planId;
      final expenseId = widget.expense.expenseId;
      
      debugPrint('업데이트할 참여자 ID 목록: $memberIds');
      debugPrint('expenseId: $expenseId, planId: $planId');

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
        ToastBar.clover('참여자가 성공적으로 수정되었습니다.');
        
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
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // 결제 내역 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '결제 내역 수정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '총 금액: ${currencyFormat.format(widget.expense.totalPayment)}원',
                      style: TextStyle(fontSize: 16, color: AppColors.primary),
                    ),
                    Text(
                      '결제일: ${widget.expense.getFormattedDate()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // 참여자 리스트
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  final currentRatio =
                      _participantRatios[participant.memberId]!;

                  return ListTile(
                    title: Text(participant.nickname),
                    subtitle: Text(
                      '분담 금액: ${currencyFormat.format((widget.expense.totalPayment * currentRatio).ceil())}원',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed:
                              _participants.length > 1
                                  ? () {
                                    setState(() {
                                      _participants.removeAt(index);
                                      _participantRatios.remove(
                                        participant.memberId,
                                      );
                                      _updateParticipantRatios();

                                      // 사용 가능한 멤버 목록에 다시 추가
                                      _availableMembers?.add(
                                        Member(
                                          memberId: participant.memberId,
                                          email: participant.email,
                                          nickname: participant.nickname,
                                          profileUrl: participant.profileUrl,
                                        ),
                                      );
                                    });
                                  }
                                  : null,
                        ),
                        SizedBox(
                          width: 100,
                          child: Slider(
                            value: currentRatio,
                            min: 0,
                            max: 1,
                            divisions: 100,
                            label:
                                '${(currentRatio * 100).toStringAsFixed(1)}%',
                            onChanged: (value) {
                              setState(() {
                                _participantRatios[participant.memberId] =
                                    value;
                                _updateParticipantRatios();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 참여자 추가 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _showAddParticipantDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('참여자 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
              ),

              // 저장 버튼
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _saveParticipants,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}