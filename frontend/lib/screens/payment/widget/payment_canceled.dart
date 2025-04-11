import 'package:flutter/material.dart';

class PaymentCanceled extends StatelessWidget {
  const PaymentCanceled({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('취소'),
      content: const Text('주문이 정상적으로 취소되었습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
