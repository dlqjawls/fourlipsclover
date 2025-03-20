import 'package:flutter/material.dart';
import 'package:frontend/models/user_payment.dart';
import 'package:frontend/config/theme.dart';
import 'package:intl/intl.dart';

class UserReceipt extends StatelessWidget {
  final Payment payment;

  const UserReceipt({Key? key, required this.payment}) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일 HH:mm').format(date);
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat("#,##0", "ko_KR");
    return "${formatter.format(amount)}원";
  }

  Widget _buildDottedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(150, (index) {
          return Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.grey : Colors.transparent,
              height: 1,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '영수증',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 로고 및 가게명
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.store, size: 40, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          '김쿨라멘',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildDottedLine(),

                  // 주문 정보
                  Text(
                    '주문 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('주문 시간', _formatDate(payment.date)),
                  _buildInfoRow('주문 번호', '#${payment.id}'),

                  _buildDottedLine(),

                  // 주문 내역
                  Text(
                    '주문 내역',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...payment.description
                      .split(',')
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            item.trim(),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ),

                  _buildDottedLine(),

                  // 결제 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 결제 금액',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        _formatCurrency(payment.amount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 감사 인사
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.mediumGray, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }
}
