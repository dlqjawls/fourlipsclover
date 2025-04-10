import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_history.dart';
import 'payment_cancel.dart';
import 'payment_canceled.dart';

class PaymentHistoryItem extends StatelessWidget {
  final PaymentHistory history;
  final VoidCallback? onCancel;

  const PaymentHistoryItem({
    super.key,
    required this.history,
    this.onCancel,
  });

  String _formatDateTime(DateTime dateTime) {
    final weekDayKor = ['월', '화', '수', '목', '금', '토', '일'];
    final formatter = DateFormat('yyyy.MM.dd');
    final timeFormatter = DateFormat('HH:mm');
    final weekDay = weekDayKor[dateTime.weekday - 1];
    return '${formatter.format(dateTime)}($weekDay) ${timeFormatter.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = history.status == 'APPROVED';
    final isCanceled = history.status == 'CANCELED';


    return ListTile(
      title: Text(
        '${history.itemName}',
        style: TextStyle(
          color: isCanceled ? Colors.grey : Colors.black,
          decoration: isCanceled ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${history.amount}원 / ${_formatDateTime(history.createdAt)}',
        style: TextStyle(
          color: isCanceled ? Colors.grey : Colors.black54,
        ),
      ),
      trailing: SizedBox(
        width: 80,
        child: Align(
          alignment: Alignment.centerRight,
          child: isCanceled
              ? const Text(
            '취소완료',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14, // 버튼과 높이 맞추기
              fontWeight: FontWeight.w500,
            ),
          )
              : TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // 버튼 높이 맞추기
              minimumSize: Size(0, 0),  // 기본 최소 크기 제거
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => PaymentCancel(
                  amount: history.amount,
                  onConfirm: () {
                    if (onCancel != null) onCancel!();

                    showDialog(
                      context: context,
                      builder: (_) => const PaymentCanceled(),
                    );
                  },
                ),
              );
            },
            child: const Text(
              '결제취소',
              style: TextStyle(
                fontSize: 14, // 텍스트 크기를 '취소 완료'와 동일하게
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
