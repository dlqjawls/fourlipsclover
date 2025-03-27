class PaymentHistory {
  final String tid; // 결제 고유 번호
  final String itemName; // 상품 이름
  final int amount; // 결제 금액
  final DateTime createdAt;
  final bool isCanceled;

  PaymentHistory({
    required this.tid,
    required this.itemName,
    required this.amount,
    required this.createdAt,
    this.isCanceled = false,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      tid: json['tid'],
      itemName: json['item_name'],
      amount: json['amount']['total'],
      createdAt: DateTime.parse(json['created_at']),
      isCanceled: json['status'] == 'CANCELLED', // 예: status가 있으면
    );
  }
}
