import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../matching/matching.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String itemName;
  final int amount;
  final String orderId;

  const PaymentSuccessScreen({
    super.key,
    required this.itemName,
    required this.amount,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 완료'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 80),
            const SizedBox(height: 16),
            const Text(
              '결제가 정상적으로 완료되었습니다!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text(' 상품명: $itemName', style: const TextStyle(fontSize: 16)),
            Text(' 결제 금액: ${amount.toString()}원', style: const TextStyle(fontSize: 16)),
            // Text(' 주문번호: $orderId', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MatchingScreen(), // 매칭 페이지로
                    ),
                        (route) => false,
                  );
                },
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}