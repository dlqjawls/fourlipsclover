import 'package:flutter/material.dart';

class PaymentCancel extends StatelessWidget {
  final int amount;
  final VoidCallback onConfirm;

  const PaymentCancel({
    Key? key,
    required this.amount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('결제를 취소하시겠습니까?'),
      content: Text('결제 금액: ${amount}원'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();             // 실제 취소 로직 실행
          },
          child: const Text('예'),
        ),
      ],
    );
  }
}
