import 'package:flutter/material.dart';
import '../../../models/payment_history.dart';
import '../../services/payment/payment_service.dart';
import 'widget/payment_history_item.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/toast_bar.dart';

class PaymentHistoryListScreen extends StatefulWidget {
  const PaymentHistoryListScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryListScreenState createState() => _PaymentHistoryListScreenState();
}

class _PaymentHistoryListScreenState extends State<PaymentHistoryListScreen> {
  late Future<List<PaymentHistory>> _futurePaymentHistory;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final memberId = Provider.of<AppProvider>(context, listen: false).user?.id.toString();

      if (memberId != null) {
        _futurePaymentHistory = PaymentService.fetchPaymentHistory(memberId: memberId);
      } else {
        _futurePaymentHistory = Future.value([]);
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
          final paymentList = snapshot.data!..sort(
                (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          return ListView.builder(
            itemCount: paymentList.length,
            itemBuilder: (context, index) {
              return PaymentHistoryItem(
                history: paymentList[index],
                onCancel: () async {
                  try {
                    await PaymentService.requestPaymentCancel(
                      tid: paymentList[index].tid,
                      cancelAmount: paymentList[index].amount,
                      cancelTaxFreeAmount: 0,
                    );
                    ToastBar.clover('결제가 취소되었습니다.');
                    setState(() {
                      final memberId = Provider.of<AppProvider>(context, listen: false).user?.id.toString();
                      if (memberId != null) {
                        _futurePaymentHistory = PaymentService.fetchPaymentHistory(memberId: memberId);
                      }
                    });
                  } catch (e) {
                    ToastBar.clover('취소 중 오류가 발생했습니다.');
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
