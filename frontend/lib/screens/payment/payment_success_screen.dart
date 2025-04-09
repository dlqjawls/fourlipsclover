import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import 'payment_history_screen.dart';
import '../../config/theme.dart';
import '../../screens/matching/matching.dart';
import 'package:provider/provider.dart';
import '../../providers/matching_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String itemName;
  final int amount;
  final String tid;

  const PaymentSuccessScreen({
    Key? key,
    required this.itemName,
    required this.amount,
    required this.tid,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  // 결제 취소 처리
  void _cancelPayment() async {
    try {
      await PaymentService.requestPaymentCancel(
        tid: widget.tid,
        cancelAmount: widget.amount,
        cancelTaxFreeAmount: 0,
      );

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('결제 취소'),
              content: const Text('결제가 정상적으로 취소되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    _navigateToMatching(); // 매칭 화면으로 이동
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    } catch (e) {
      print('❌ 결제 취소 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('결제 취소 실패: $e')));
    }
  }

  void _navigateToMatching() {
    // 모든 화면을 제거하고 메인 화면으로 이동한 후 매칭 화면으로 이동
    Navigator.of(context).popUntil((route) => route.isFirst); // 메인 화면까지 pop
    Navigator.pushNamed(context, '/matching'); // 매칭 화면으로 이동
  }

  @override
  Widget build(BuildContext context) {
    const String userId = '3963528811'; // TODO: 나중에 실제 로그인 값으로 교체

    return Scaffold(
      appBar: AppBar(title: const Text('결제 완료'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.itemName} 결제가 완료되었습니다.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '결제 금액: ${widget.amount}원',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // 버튼 컨테이너
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 상단 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => PaymentHistoryListScreen(
                                      memberId: userId,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text('결제 내역'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _cancelPayment,
                          icon: const Icon(Icons.cancel, size: 20),
                          label: const Text('결제 취소'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 매칭 목록 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToMatching,
                      icon: const Icon(Icons.list, size: 20),
                      label: const Text('매칭 목록으로 이동'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
