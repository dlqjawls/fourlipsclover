import 'package:flutter/material.dart';
import '../../../models/payment_history.dart';
import 'widget/payment_history_item.dart'; // 결제 아이템 위젯 import

class PaymentHistoryListScreen extends StatelessWidget {
  const PaymentHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 결제 데이터 예시
    final List<PaymentHistory> paymentList = [
      PaymentHistory(
        paymentId: 'pay001',
        guideName: '현지인 매칭(김가이드)',
        amount: 3000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isCanceled: false,
      ),
      PaymentHistory(
        paymentId: 'pay002',
        guideName: '현지인 매칭(이가이드)',
        amount: 1000,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isCanceled: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('결제 내역'),
        centerTitle: true,),

      body: ListView.builder(
        itemCount: paymentList.length,
        itemBuilder: (context, index) {
          return PaymentHistoryItem(
            history: paymentList[index],
            onCancel: () {
              // 예시: 취소 처리 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결제가 취소되었습니다.')),
              );
            },
          );
        },
      ),
    );
  }
}
