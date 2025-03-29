import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';

// 결제 항목 모델 (임시)
class PaymentItem {
  final String id;
  final String title;
  final double amount;
  final String payerNickname;
  final int payerId;
  final DateTime paymentDate;
  final List<int> participantIds; // 참여자 ID 목록

  PaymentItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerNickname,
    required this.payerId,
    required this.paymentDate,
    required this.participantIds,
  });
}

class PlanSettlementView extends StatefulWidget {
  final int planId;
  final int groupId;
  final List<dynamic> members; // 멤버 목록 (Member 타입)
  final String? planTitle; // 여행 제목 (옵션)

  const PlanSettlementView({
    Key? key,
    required this.planId,
    required this.groupId,
    required this.members,
    this.planTitle,
  }) : super(key: key);

  @override
  State<PlanSettlementView> createState() => _PlanSettlementViewState();
}

class _PlanSettlementViewState extends State<PlanSettlementView> {
  List<PaymentItem> _payments = []; // 결제 항목 목록
  bool _isLoading = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int? _selectedPayerId; // 결제자 ID
  final Set<int> _selectedParticipantIds = {}; // 참여자 ID 집합

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 결제 내역 로드 (임시 데이터)
  Future<void> _loadPayments() async {
    if (!mounted) return; // 위젯이 이미 dispose된 경우 중단

    setState(() {
      _isLoading = true;
    });

    // 임시 데이터 생성 (실제로는 API에서 가져와야 함)
    await Future.delayed(const Duration(milliseconds: 800));

    // mounted 체크 추가
    if (!mounted) return;

    setState(() {
      _payments = [
        PaymentItem(
          id: '1',
          title: '렌트카 대여료',
          amount: 150000,
          payerNickname: '영희',
          payerId: 2,
          paymentDate: DateTime.now().subtract(const Duration(days: 2)),
          participantIds: [1, 2, 3, 4],
        ),
        PaymentItem(
          id: '2',
          title: '숙소 예약금',
          amount: 120000,
          payerNickname: '철수',
          payerId: 1,
          paymentDate: DateTime.now().subtract(const Duration(days: 5)),
          participantIds: [1, 2, 3, 4],
        ),
        PaymentItem(
          id: '3',
          title: '성산일출봉 입장료',
          amount: 24000,
          payerNickname: '민수',
          payerId: 3,
          paymentDate: DateTime.now().subtract(const Duration(days: 1)),
          participantIds: [1, 3, 4],
        ),
        PaymentItem(
          id: '4',
          title: '저녁 식사',
          amount: 88000,
          payerNickname: '영희',
          payerId: 2,
          paymentDate: DateTime.now().subtract(const Duration(hours: 5)),
          participantIds: [1, 2, 3, 4],
        ),
      ];
      _isLoading = false;
    });
  }

  // 결제 항목 추가 다이얼로그 표시
  void _showAddPaymentDialog() {
    // 입력 필드 초기화
    _titleController.clear();
    _amountController.clear();
    _selectedPayerId = null;
    _selectedParticipantIds.clear();

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (stContext, setDialogState) => AlertDialog(
                  title: const Text('결제 내역 추가'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 항목명
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: '항목명',
                            hintText: '예: 식사, 숙소, 교통비 등',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 금액
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: '금액 (원)',
                            hintText: '예: 50000',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // 결제자 선택
                        const Text('결제자'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              widget.members.map((member) {
                                final memberId = member.memberId;
                                final isSelected = _selectedPayerId == memberId;
                                return FilterChip(
                                  label: Text(member.nickname),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    // StatefulBuilder의 setState 사용
                                    setDialogState(() {
                                      _selectedPayerId =
                                          selected ? memberId : null;
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // 참여자 선택
                        const Text('참여자'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              widget.members.map((member) {
                                final memberId = member.memberId;
                                final isSelected = _selectedParticipantIds
                                    .contains(memberId);
                                return FilterChip(
                                  label: Text(member.nickname),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    // StatefulBuilder의 setState 사용
                                    setDialogState(() {
                                      if (selected) {
                                        _selectedParticipantIds.add(memberId);
                                      } else {
                                        _selectedParticipantIds.remove(
                                          memberId,
                                        );
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 유효성 검사
                        if (_titleController.text.trim().isEmpty ||
                            _amountController.text.trim().isEmpty ||
                            _selectedPayerId == null ||
                            _selectedParticipantIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                          );
                          return;
                        }

                        // 정산 추가 (임시 구현)
                        final double amount;
                        try {
                          amount = double.parse(_amountController.text.trim());
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('유효한 금액을 입력해주세요.')),
                          );
                          return;
                        }

                        // 결제자 닉네임 찾기
                        final payer = widget.members.firstWhere(
                          (m) => m.memberId == _selectedPayerId,
                          orElse: () => null,
                        );
                        if (payer == null) return;

                        final newPayment = PaymentItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text.trim(),
                          amount: amount,
                          payerNickname: payer.nickname,
                          payerId: _selectedPayerId!,
                          paymentDate: DateTime.now(),
                          participantIds: _selectedParticipantIds.toList(),
                        );

                        // 다이얼로그를 닫고 상태 업데이트
                        Navigator.pop(dialogContext);

                        // mounted 체크 추가
                        if (mounted) {
                          setState(() {
                            _payments.insert(0, newPayment);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('추가'),
                    ),
                  ],
                ),
          ),
    );
  }

  // 총액 계산
  double get _totalAmount {
    return _payments.fold(0, (sum, item) => sum + item.amount);
  }

  // 멤버별 정산 내역 계산
  Map<int, Map<String, dynamic>> _calculateSettlement() {
    final Map<int, double> paid = {}; // 각 멤버가 지불한 금액
    final Map<int, double> share = {}; // 각 멤버가 부담해야 할 금액
    final Map<int, Map<String, dynamic>> result = {}; // 최종 결과

    // 초기화
    for (var member in widget.members) {
      paid[member.memberId] = 0;
      share[member.memberId] = 0;
      result[member.memberId] = {
        'nickname': member.nickname,
        'paid': 0.0,
        'share': 0.0,
        'balance': 0.0, // 양수: 받을 금액, 음수: 지불할 금액
      };
    }

    // 각 결제 항목에 대해 계산
    for (var payment in _payments) {
      // 결제자가 지불한 금액 추가
      paid[payment.payerId] = (paid[payment.payerId] ?? 0) + payment.amount;

      // 참여자별 부담 금액 계산
      final perPersonShare = payment.amount / payment.participantIds.length;
      for (var participantId in payment.participantIds) {
        share[participantId] = (share[participantId] ?? 0) + perPersonShare;
      }
    }

    // 최종 정산 결과 계산
    for (var memberId in paid.keys) {
      final paidAmount = paid[memberId] ?? 0;
      final shareAmount = share[memberId] ?? 0;
      final balance = paidAmount - shareAmount; // 양수: 받을 금액, 음수: 지불할 금액

      if (result.containsKey(memberId)) {
        result[memberId]!['paid'] = paidAmount;
        result[memberId]!['share'] = shareAmount;
        result[memberId]!['balance'] = balance;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // 멤버별 정산 내역
    final settlementResult = _calculateSettlement();

    // 숫자 포맷터
    final currencyFormat = NumberFormat('#,###', 'ko_KR');

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // 상단 정보 및 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '여행 정산',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '총 ${_payments.length}건, ${currencyFormat.format(_totalAmount)}원',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('결제 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 정산 내역 영수증
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _payments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '등록된 결제 내역이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '결제 내역을 추가하여 정산을 시작해보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // 영수증 형태 결제 목록
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // 영수증 헤더
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${widget.planTitle ?? '여행'} 정산 내역',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '총액: ${currencyFormat.format(_totalAmount)}원',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 영수증 내용
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          '항목',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '결제자',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '금액',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 구분선
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                  height: 1,
                                ),

                                // 결제 항목 목록
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _payments.length,
                                  separatorBuilder:
                                      (context, index) => Divider(
                                        color: Colors.grey.shade200,
                                        height: 1,
                                      ),
                                  itemBuilder: (context, index) {
                                    final payment = _payments[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          // 항목명
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              payment.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          // 결제자
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              payment.payerNickname,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          // 금액
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${currencyFormat.format(payment.amount)}원',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // 영수증 푸터 (총액)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '합계',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${currencyFormat.format(_totalAmount)}원',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 정산 결과 (멤버별)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 정산 결과 헤더
                                const Text(
                                  '정산 결과',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 멤버별 정산 내역
                                Column(
                                  children:
                                      settlementResult.values.map((
                                        memberResult,
                                      ) {
                                        final nickname =
                                            memberResult['nickname'];
                                        final paid =
                                            memberResult['paid'] as double;
                                        final share =
                                            memberResult['share'] as double;
                                        final balance =
                                            memberResult['balance'] as double;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                balance > 0
                                                    ? Colors.green.shade50
                                                    : balance < 0
                                                    ? Colors.red.shade50
                                                    : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  balance > 0
                                                      ? Colors.green.shade200
                                                      : balance < 0
                                                      ? Colors.red.shade200
                                                      : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 닉네임
                                              Text(
                                                nickname,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // 지불 및 부담 금액
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '지불한 금액: ${currencyFormat.format(paid)}원',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '부담할 금액: ${currencyFormat.format(share)}원',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // 정산 결과
                                              Text(
                                                balance > 0
                                                    ? '받을 금액: ${currencyFormat.format(balance)}원'
                                                    : balance < 0
                                                    ? '보낼 금액: ${currencyFormat.format(-balance)}원'
                                                    : '정산 완료',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      balance > 0
                                                          ? Colors
                                                              .green
                                                              .shade700
                                                          : balance < 0
                                                          ? Colors.red.shade700
                                                          : Colors
                                                              .grey
                                                              .shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
