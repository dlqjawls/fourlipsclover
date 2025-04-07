import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/plan_provider.dart';
import '../../../providers/settlement_provider.dart';
import '../../../models/settlement/settlement_model.dart';
import 'dart:convert';

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
  Settlement? _settlement; // 정산 데이터
  bool _isLoading = true;
  String? _errorMessage;

  // 여행 시작일과 종료일을 저장할 변수
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Future.microtask를 사용하여 빌드 후 로드
    Future.microtask(() {
      _loadPlanDates(); // 여행 날짜 로드
      _loadSettlementData(); // 정산 데이터 로드
    });
  }

  // 여행 날짜 로드 메서드
  Future<void> _loadPlanDates() async {
    if (!mounted) return;

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final planDetail = await planProvider.fetchPlanDetail(
        widget.groupId,
        widget.planId,
      );

      if (!mounted) return;

      setState(() {
        _startDate = planDetail.startDate;
        _endDate = planDetail.endDate;
      });
    } catch (e) {
      debugPrint('여행 날짜 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '여행 정보를 불러오는데 실패했습니다.';
        });
      }
    }
  }

  // 정산 데이터 로드 메서드
  Future<void> _loadSettlementData() async {
    if (!mounted) return;

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    try {
      // 정산 상세 정보 조회
      final settlement = await settlementProvider.fetchSettlementDetail(
        widget.planId,
      );
      debugPrint(jsonEncode(settlement));

      if (!mounted) return;

      setState(() {
        _settlement = settlement;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('정산 데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 정보를 불러오는데 실패했습니다.';
        });
      }
    }
  }

  // 정산 생성 메서드
  Future<void> _createSettlement() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    try {
      // 정산 생성 API 호출
      final result = await settlementProvider.createSettlement(widget.planId);

      if (!mounted) return;

      if (result) {
        // 성공 시 정산 데이터 다시 로드
        await _loadSettlementData();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('정산이 성공적으로 생성되었습니다.')));
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 생성에 실패했습니다.';
        });
      }
    } catch (e) {
      debugPrint('정산 생성 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 생성에 실패했습니다: $e';
        });
      }
    }
  }

  // 여행 날짜 포맷 메서드
  String _formatTravelDate() {
    if (_startDate == null || _endDate == null) {
      return '날짜 정보 없음';
    }

    final startFormat = DateFormat('yyyy.MM.dd');
    final endFormat = DateFormat('dd');

    final start = startFormat.format(_startDate!);
    final end = endFormat.format(_endDate!);

    return '$start~$end';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSettlementData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 정산 데이터가 없는 경우 (아직 생성되지 않은 경우)
    if (_settlement == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.mediumGray,
            ),
            const SizedBox(height: 20),
            Text(
              '아직 정산이 생성되지 않았습니다.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '여행 계획에 대한 정산을 생성해보세요!',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _createSettlement,
              icon: const Icon(Icons.add),
              label: const Text('정산 생성하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 정산이 있지만 비용 항목이 없는 경우
    if (_settlement!.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.mediumGray,
            ),
            const SizedBox(height: 20),
            Text(
              '등록된 결제 내역이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '여행 중 발생한 비용을 카카오페이로 결제하면\n자동으로 여기에 표시됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
          ],
        ),
      );
    }

    // 정산 데이터가 있는 경우 영수증 형태로 표시
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          width: MediaQuery.of(context).size.width * 0.75,
          child: ReceiptWidget(
            settlement: _settlement!,
            planTitle: widget.planTitle ?? '여행 계획',
            date: _formatTravelDate(),
          ),
        ),
      ),
    );
  }
}

// 영수증 스타일 위젯
class ReceiptWidget extends StatelessWidget {
  final Settlement settlement;
  final String planTitle;
  final String date;

  const ReceiptWidget({
    Key? key,
    required this.settlement,
    required this.planTitle,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 숫자 포맷터
    final currencyFormat = NumberFormat('#,###', 'ko_KR');

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
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
                          fontSize: 20,
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
                          '# $planTitle',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 14,
                            color: AppColors.darkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),

                // 구분선
                _buildDottedLine(),

                // 영수증 항목들
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    minHeight: 200,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: settlement.expenses.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final expense = settlement.expenses[index];
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
                                    '결제 #${expense.paymentApprovalId}',
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontSize: 14,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat(
                                      'yyyy.MM.dd HH:mm',
                                    ).format(expense.approvedAt),
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
                              '${currencyFormat.format(expense.totalPayment)}',
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(settlement.totalAmount)}',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
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
                        height: 50,
                        width: 200,
                        child: CustomPaint(painter: BarcodePainter()),
                      ),
                    ],
                  ),
                ),

                // 푸터
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'GOOD LUCK',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 왼쪽 상단 테이프
          Positioned(top: 10, left: -57, child: _buildTapeTop()),

          // 오른쪽 하단 테이프
          Positioned(bottom: 7, right: -56, child: _buildTapeBottom()),
        ],
      ),
    );
  }

  // 투명 테이프 위젯 (사선 모양)
  Widget _buildTapeTop() {
    return Transform.rotate(
      angle: -0.8, // 약간 기울어진 모양
      child: ClipPath(
        clipper: TapeClipper(),
        child: Container(
          width: 140,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildTapeBottom() {
    return Transform.rotate(
      angle: 2.3, // 약간 기울어진 모양
      child: ClipPath(
        clipper: TapeClipper(),
        child: Container(
          width: 140,
          height: 40,
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
