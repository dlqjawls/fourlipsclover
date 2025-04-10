import 'package:flutter/material.dart';
import '../payment/payment_history_screen.dart';
import '../../config/theme.dart';
import '../payment/widget/payment_history_button.dart'; // 버튼 위젯 import

class AIPlanScreen extends StatelessWidget {
  const AIPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 추천')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '스토리',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            // 버튼 삽입
            PaymentHistoryButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentHistoryListScreen(), // memberId 제거!
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
