import 'dart:io';
import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class KakaoPayScreen extends StatelessWidget {
  const KakaoPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRealDevice = Platform.isAndroid;
    final pgCode = 'kakaopay.TC0ONETIME'; // 테스트 PG

    return IamportPayment(
      appBar: AppBar(title: const Text("카카오페이 결제")),
      initialChild: const Center(child: Text('결제창을 준비 중입니다...')),
      userCode: 'imp72504307', // 포트원 테스트용 userCode
      data: PaymentData(
        pg: pgCode, // 공기계는 실제 PG, 에뮬레이터는 테스트 PG
        payMethod: 'card',
        name: '매칭결제',
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
        amount: 10000,
        buyerName: '홍길동',
        buyerTel: '010-1234-5678',
        buyerEmail: 'hong@example.com',
        appScheme: 'testscheme', // AndroidManifest.xml
      ),
      callback: (Map<String, String> result) {
        print("결제 결과: $result");
        final success = result['success'] == 'true';

        // 결과 Alert
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(success ? '🎉 결제 성공' : '❌ 결제 실패'),
            content: Text(success
                ? '결제 완료!\nimp_uid: ${result['imp_uid']}'
                : '에러: ${result['error_msg']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }
}
