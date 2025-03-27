import 'package:flutter/material.dart';
import '../../../models/payment_history.dart';
import '../../services/payment_service.dart';
import 'widget/payment_history_item.dart';

class PaymentHistoryListScreen extends StatefulWidget {
  final String memberId;
  const PaymentHistoryListScreen({Key? key, required this.memberId}) : super(key: key);

  @override
  _PaymentHistoryListScreenState createState() => _PaymentHistoryListScreenState();
}

class _PaymentHistoryListScreenState extends State<PaymentHistoryListScreen> {
  late Future<List<PaymentHistory>> _futurePaymentHistory;

  @override
  void initState() {
    super.initState();
    _futurePaymentHistory = PaymentService.fetchPaymentHistory(memberId: widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 내역'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PaymentHistory>>(
        future: _futurePaymentHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          final paymentList = snapshot.data!;
          return ListView.builder(
            itemCount: paymentList.length,
            itemBuilder: (context, index) {
              return PaymentHistoryItem(
                history: paymentList[index],
                onCancel: () async {
                  try {
                    await PaymentService.requestPaymentCancel(
                      // paymentId를 사용합니다.
                      tid: paymentList[index].paymentId,
                      // 결제 금액은 바로 amount를 사용합니다.
                      cancelAmount: paymentList[index].amount,
                      cancelTaxFreeAmount: 0, // 예시로 0 처리
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('결제가 취소되었습니다.')),
                    );
                    setState(() {
                      _futurePaymentHistory = PaymentService.fetchPaymentHistory(memberId: widget.memberId);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('취소 오류: $e')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
