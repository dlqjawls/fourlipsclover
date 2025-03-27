import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import 'payment_history_screen.dart'; // 리스트 화면 import
import '../../config/theme.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String itemName;
  final int amount;
  final String tid;

  const PaymentSuccessScreen({
    Key? key,
    required this.itemName,
    required this.amount,
    required this.tid,
  }) : super(key: key);

  // 결제 취소 처리
  void _cancelPayment(BuildContext context) async {
    try {
      await PaymentService.requestPaymentCancel(
        tid: tid,
        cancelAmount: amount,
        cancelTaxFreeAmount: 0,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('결제 취소'),
          content: const Text('결제가 정상적으로 취소되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ 결제 취소 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 취소 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String userId = '3963528811'; // TODO: 나중에 실제 로그인 값으로 교체

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 완료'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              '$itemName 결제가 완료되었습니다.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text('결제 금액: ${amount}원', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            // 👉 버튼 두 개 가로로 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentHistoryListScreen(memberId: userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('결제 내역 보기'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _cancelPayment(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('결제 취소'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
