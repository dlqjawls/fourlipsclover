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

                // 영수증 항목들
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                  itemCount: settlement.expenses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
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

                // 바코드 (터치 가능)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                    onTap: () {
                      _showExpenseListBottomSheet(context);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 200,
                          child: CustomPaint(painter: const BarcodePainter()),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '터치하여 결제 내역 상세 보기',
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

  // 결제 내역 상세 보기 바텀시트를 표시하는 메서드
  void _showExpenseListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 드래그 핸들
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          '결제 내역 상세',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('닫기'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 결제 내역 리스트
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: settlement.expenses.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final expense = settlement.expenses[index];
                        final currencyFormat = NumberFormat('#,###', 'ko_KR');

                        return ListTile(
                          title: Text(
                            '결제 #${expense.paymentApprovalId}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'yyyy.MM.dd HH:mm',
                                ).format(expense.approvedAt),
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '참여자: ${expense.expenseParticipants.map((p) => p.nickname).join(', ')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currencyFormat.format(expense.totalPayment)}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  // 바텀시트 닫기
                                  Navigator.pop(context);

                                  // ExpenseEditBottomSheet 호출
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
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // 항목을 터치해도 편집 화면으로 이동
                            Navigator.pop(context);
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
                              if (onSettlementRequested != null) {
                                onSettlementRequested!();
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // 하단 정산 정보
                  if (settlement.settlementStatus == SettlementStatus.PENDING)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _requestSettlement(context);
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('정산 요청하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 정산 요청 메서드
  void _requestSettlement(BuildContext context) async {
    // 재확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정산 요청 확인'),
        content: const Text(
          '모든 멤버에게 정산 요청을 보내시겠습니까?\n이 작업은 취소할 수 없습니다.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mediumGray),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('확인'),
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