import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/plan_provider.dart';

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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int? _selectedPayerId; // 결제자 ID
  final Set<int> _selectedParticipantIds = {}; // 참여자 ID 집합
  bool _isLoading = true; // 초기값을 true로 설정

  @override
  void initState() {
    super.initState();
    // Future.microtask를 사용하여 빌드 후 로드
    Future.microtask(() => _loadPayments());
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

    try {
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
          PaymentItem(
            id: '5',
            title: '카페 음료',
            amount: 32000,
            payerNickname: '민수',
            payerId: 3,
            paymentDate: DateTime.now().subtract(const Duration(days: 3)),
            participantIds: [1, 2, 3, 4],
          ),
          PaymentItem(
            id: '6',
            title: '기념품 구매',
            amount: 45000,
            payerNickname: '철수',
            payerId: 1,
            paymentDate: DateTime.now().subtract(const Duration(days: 4)),
            participantIds: [1, 3, 4],
          ),
          PaymentItem(
            id: '7',
            title: '택시비',
            amount: 28000,
            payerNickname: '영희',
            payerId: 2,
            paymentDate: DateTime.now().subtract(
              const Duration(days: 2, hours: 12),
            ),
            participantIds: [1, 2, 3, 4],
          ),
          PaymentItem(
            id: '8',
            title: '해변 파라솔 대여',
            amount: 15000,
            payerNickname: '민수',
            payerId: 3,
            paymentDate: DateTime.now().subtract(
              const Duration(days: 3, hours: 4),
            ),
            participantIds: [1, 3, 4],
          ),
          PaymentItem(
            id: '9',
            title: '점심 식사',
            amount: 75000,
            payerNickname: '철수',
            payerId: 1,
            paymentDate: DateTime.now().subtract(
              const Duration(days: 1, hours: 8),
            ),
            participantIds: [1, 2, 3, 4],
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('결제 내역 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // 에러 발생 시 빈 리스트로 설정
          _payments = [];
        });
      }
    }
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
                        double amount;
                        try {
                          amount = double.parse(_amountController.text.trim());
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('유효한 금액을 입력해주세요.')),
                          );
                          return;
                        }

                        // 결제자 닉네임 찾기
                        final membersList = widget.members.toList();
                        final payerIndex = membersList.indexWhere(
                          (m) => m.memberId == _selectedPayerId,
                        );

                        if (payerIndex == -1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('결제자를 찾을 수 없습니다.')),
                          );
                          return;
                        }

                        final payer = membersList[payerIndex];

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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 30,
              ), // 위아래 여백 추가 (테이프가 잘리지 않도록)
              width: MediaQuery.of(context).size.width * 0.75, // 영수증 너비 조정
              child: ReceiptWidget(
                payments: _payments,
                planTitle: widget.planTitle ?? '여행 계획',
                onAddPayment: _showAddPaymentDialog,
              ),
            ),
          ),
        );
  }
}

// 영수증 스타일 위젯
class ReceiptWidget extends StatelessWidget {
  final List<PaymentItem> payments;
  final String? planTitle;
  final VoidCallback onAddPayment;
  final String date;

  const ReceiptWidget({
    Key? key,
    required this.payments,
    this.planTitle,
    required this.onAddPayment,
    this.date = '2020.12.17~19', // 기본값 설정
  }) : super(key: key);

  // 총액 계산
  double get _totalAmount {
    return payments.fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    // 숫자 포맷터
    final currencyFormat = NumberFormat('#,###', 'ko_KR');
    final startDate =
        planTitle != null && planTitle!.contains("2023")
            ? "2023.09.15~17" // 임시 날짜 설정 (나중에 실제 데이터로 대체)
            : date;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16), // 여백 추가
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 영수증 본체
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
              children: [
                // 영수증 제목
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '네잎네산',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 20, // 글자 크기 줄임
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/clover.png',
                        width: 30,
                        height: 30,
                      ),
                    ],
                  ),
                ),

                // 구분선
                _buildDottedLine(),

                // 여행지 정보
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          planTitle ?? '여행 계획',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 14, // 글자 크기 줄임
                            color: AppColors.darkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        startDate,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14, // 글자 크기 줄임
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),

                // 구분선
                _buildDottedLine(),

                // 영수증 항목들
                if (payments.isEmpty)
                  _buildEmptyPaymentsView()
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.4, // 스크롤 가능한 최대 높이 설정
                      minHeight: 200,
                    ),

                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: payments.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.title,
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 14,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat(
                                        'yyyy.MM.dd',
                                      ).format(payment.paymentDate),
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 10,
                                        color: AppColors.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${currencyFormat.format(payment.amount)}',
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // 구분선
                _buildDottedLine(),

                // 총액
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 지출액',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16, // 글자 크기 줄임
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(_totalAmount)}',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16, // 글자 크기 줄임
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),

                // 구분선
                _buildDottedLine(),

                // 바코드
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 50, // 바코드 높이 줄임
                        width: 200, // 바코드 너비 줄임
                        child: CustomPaint(painter: BarcodePainter()),
                      ),
                    ],
                  ),
                ),

                // 푸터
                const Padding(
                  padding: EdgeInsets.only(bottom: 24), // 패딩 줄임
                  child: Text(
                    'GOOD LUCK',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14, // 글자 크기 줄임
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 왼쪽 상단 테이프
          Positioned(top: 5, left: -60, child: _buildTape()),

          // 오른쪽 하단 테이프
          Positioned(bottom: -10, right: -35, child: _buildTape()),
        ],
      ),
    );
  }

  // 투명 테이프 위젯 (사선 모양)
  Widget _buildTape() {
    return Transform.rotate(
      angle: -0.7, // 약간 기울어진 모양
      child: ClipPath(
        clipper: TapeClipper(),
        child: Container(
          width: 150,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  // 점선 구분선 위젯
  Widget _buildDottedLine() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      height: 1,
      child: CustomPaint(
        painter: DottedLinePainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }

  // 비어있는 경우 위젯
  Widget _buildEmptyPaymentsView() {
    return Container(
      height: 180, // 빈 상태 높이 줄임
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 등록된 결제 내역이 없습니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontFamily: 'Anemone_air',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddPayment,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('결제 내역 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 테이프 모양을 위한 클리퍼
class TapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5); // 왼쪽 하단 모서리에서 시작
    path.lineTo(size.width * 0.1, 0); // 왼쪽 상단 모서리
    path.lineTo(size.width, 0); // 오른쪽 상단 모서리
    path.lineTo(size.width, size.height); // 오른쪽 하단 모서리
    path.lineTo(size.width * 0.1, size.height); // 왼쪽 하단 모서리
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 점선 그리기 위한 CustomPainter
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    double dashWidth = 5, dashSpace = 5, startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 바코드 그리기 위한 CustomPainter
class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final random = List.generate(
      50,
      (index) => index * 3.0 + (index % 3) * 2.0,
    );
    double startX = 0;

    for (int i = 0; i < random.length; i++) {
      // 각 바코드 라인의 두께와 간격 설정
      final lineWidth = i % 4 == 0 ? 3.0 : 1.5;
      final spaceWidth = 2.0;

      // 바코드 선 그리기
      canvas.drawRect(Rect.fromLTWH(startX, 0, lineWidth, size.height), paint);

      startX += lineWidth + spaceWidth;

      // 바코드가 영역을 벗어나면 그리기 중단
      if (startX > size.width) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
