import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/user_model.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatelessWidget {
  final List<RecentPayment> payments;

  const PaymentHistory({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            Center(
              child: Text(
                '결제 내역이 없습니다',
                style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return PaymentItem(payment: payment);
              },
            ),
        ],
      ),
    );
  }
}

class PaymentItem extends StatelessWidget {
  final RecentPayment payment;

  const PaymentItem({super.key, required this.payment});

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,##0", "ko_KR");
    return "${formatter.format(amount)}원";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            payment.storeName,
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
          Text(
            payment.paymentAmount != null
                ? formatCurrency(payment.paymentAmount!)
                : '0원',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
