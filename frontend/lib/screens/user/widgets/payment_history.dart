import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '결제 내역',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildPaymentCard('총 비용 : 2천원'),
        _buildDivider(),
        _buildPaymentCard('총 비용 : 3천원'),
        _buildDivider(),
        _buildPaymentCard('총 비용 : 5천원'),
      ],
    );
  }

  Widget _buildPaymentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.more_vert),
        ],
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
