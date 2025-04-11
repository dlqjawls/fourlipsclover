class PaymentHistory {
  final String tid; // 결제 고유 번호
  final String itemName; // 상품 이름
  final int amount; // 결제 금액
  final DateTime createdAt;
  final bool isCanceled;
  final String status;

  PaymentHistory({
    required this.tid,
    required this.itemName,
    required this.amount,
    required this.createdAt,
    this.isCanceled = false,
    required this.status,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    final amountMap = json['amount'];
    final totalAmount = (amountMap is Map && amountMap.containsKey('total'))
        ? amountMap['total'] as int
        : 0;

    return PaymentHistory(
      tid: json['tid'] ?? '',
      itemName: json['item_name'] ?? '',
      amount: totalAmount,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isCanceled: json['status'] == 'CANCELED',
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}