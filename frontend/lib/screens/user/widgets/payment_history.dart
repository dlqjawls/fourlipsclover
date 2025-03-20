import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/user_payment.dart';
import 'package:frontend/screens/user/user_receipt.dart';
import 'package:frontend/services/payment_history_service.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

String formatCurrency(int amount) {
  final formatter = NumberFormat("#,##0", "ko_KR");
  return "${formatter.format(amount)}원"; // 10,000원 형식 출력
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final payments = await _paymentService.getPaymentHistory();
      print('로드된 결제 내역: ${payments.length}개'); // 디버깅용 로그 추가
      setState(() => _payments = payments);
    } catch (e) {
      print('결제 내역 로딩 에러: $e'); // 에러 로그 개선
      setState(() => _payments = []); // 에러 시 빈 배열로 설정
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('현재 결제 내역 수: ${_payments.length}개'); // 디버깅용 로그 추가
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '결제 내역',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_payments.isEmpty) // 빈 상태 처리 추가
          const Center(child: Text('결제 내역이 없습니다.'))
        else
          ..._payments
              .map(
                (payment) => Column(
                  children: [
                    _buildPaymentCard(context, payment),
                    _buildDivider(),
                  ],
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserReceipt(payment: payment),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.description, style: const TextStyle(fontSize: 16)),
                Text(
                  '총 비용: ${formatCurrency(payment.amount)}', // formatCurrency 함수만 사용
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: AppColors.lightGray)),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGray,
          ),
        ),
      ],
    );
  }
}
