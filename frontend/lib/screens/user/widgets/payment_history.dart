import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/user_model.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatelessWidget {
  final List<Payment> payments;
  
  const PaymentHistory({
    super.key,
    required this.payments,
  });

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,##0", "ko_KR");
    return "${formatter.format(amount)}원";
  }

@override
Widget build(BuildContext context) {
  return Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,  // 영수증 아이콘 추가
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '최근 결제 내역',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            const Center(
              child: Text(
                '결제 내역이 없습니다.',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 14,
                ),
              ),
            )
          else
            ...payments.map((payment) => Column(
              children: [
                _buildPaymentCard(context, payment),
                if (payments.last != payment) _buildDivider(),
              ],
            )).toList(),
        ],
      ),
    ),
  );
}
  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.storeName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                payment.menu,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGray
                ),
              ),
              Text(
                formatCurrency(payment.paymentAmount),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: AppColors.lightGray,
      ),
    );
  }
}