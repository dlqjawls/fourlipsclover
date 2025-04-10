// lib/screens/settlement/plan_widgets/settlement/receipt_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../models/settlement/settlement_model.dart';
import '../../../../providers/settlement_provider.dart';
import '../../../../widgets/toast_bar.dart';
import '../../bottomsheet/settlement/expense_edit_bottom_sheet.dart';
import 'receipt_painters.dart';

/// 영수증 스타일 위젯
class ReceiptWidget extends StatelessWidget {
  final Settlement settlement;
  final String planTitle;
  final String date;
  final int planId;
  final int groupId;
  final VoidCallback? onSettlementRequested;

  const ReceiptWidget({
    Key? key,
    required this.settlement,
    required this.planTitle,
    required this.date,
    required this.planId,
    required this.groupId,
    this.onSettlementRequested,
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

                // 영수증 항목들 - 터치하면 바로 수정 바텀시트 열림
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                  itemCount: settlement.expenses.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final expense = settlement.expenses[index];
                    return InkWell(
                      onTap: () {
                        // 직접 결제 항목 클릭 시 수정 바텀시트 열기
                        _showExpenseEditBottomSheet(context, expense);
                      },
                      child: Padding(
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
                                    expense.itemName,
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
                              '${currencyFormat.format(expense.totalPayment)} 원',
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
                    );
                  },
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
                        '${currencyFormat.format(settlement.totalAmount)} 원',
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

                // 바코드 (정산 요청 기능으로 변경)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                    onTap: () {
                      // 이제 바코드는 정산 요청 기능으로 변경
                      _requestSettlement(context);
                    },
                    child: Column(
                      children: [
                        // 바코드와 스캔 라인을 함께 표시하는 Stack
                        SizedBox(
                          height: 50,
                          width: 200,
                          child: Stack(
                            children: [
                              // 기존 바코드를 확실하게 표시
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: const BarcodePainter(),
                                ),
                              ),

                              // 스캔 라인 애니메이션 추가
                              ScanningLine(
                                isEnabled:
                                    settlement.settlementStatus ==
                                    SettlementStatus.PENDING,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settlement.settlementStatus ==
                                  SettlementStatus.PENDING
                              ? '터치하여 정산 요청하기'
                              : '정산 요청 완료',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
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

  // 결제 내역 수정 바텀시트 표시
  void _showExpenseEditBottomSheet(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ExpenseEditBottomSheet(
          expense: expense,
          planId: planId,
          groupId: groupId,
        );
      },
    ).then((_) {
      // 편집 후 데이터 새로고침
      if (onSettlementRequested != null) {
        onSettlementRequested!();
      }
    });
  }

  // 정산 요청 메서드
  void _requestSettlement(BuildContext context) async {
    // 이미 정산 요청이 된 경우 처리하지 않음
    if (settlement.settlementStatus != SettlementStatus.PENDING) {
      ToastBar.clover('이미 정산 요청이 완료되었습니다.');
      return;
    }

    // 비용이 없으면 정산 요청 불가
    if (settlement.expenses.isEmpty) {
      ToastBar.clover('등록된 결제 내역이 없습니다.');
      return;
    }

    // 재확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('정산 요청 확인'),
            content: const Text(
              '모든 멤버에게 정산 요청을 보내시겠습니까?',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumGray,
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(color: AppColors.background),
                ),
              ),
            ],
          ),
    );

    // 사용자가 취소한 경우
    if (confirmed != true) return;

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await settlementProvider.requestSettlement(planId);

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      if (result != null) {
        // 정산 요청 성공
        ToastBar.clover('정산 요청 완료');

        // 정산 현황 화면으로 이동
        Navigator.pushNamed(
          context,
          '/settlement/situation',
          arguments: {'planId': planId, 'planTitle': planTitle},
        );

        // 콜백 호출
        if (onSettlementRequested != null) {
          onSettlementRequested!();
        }
      } else {
        ToastBar.clover('정산 요청 실패');
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 오류 메시지
      ToastBar.clover('정산 요청 오류 $e');
    }
  }

  // 투명 테이프 위젯 (사선 모양)
  Widget _buildTapeTop() {
    return Transform.rotate(
      angle: -0.8, // 약간 기울어진 모양
      child: ClipPath(
        clipper: const TapeClipper(),
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
        clipper: const TapeClipper(),
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
        painter: const DottedLinePainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }
}
