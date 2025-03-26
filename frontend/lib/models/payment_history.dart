class PaymentHistory {
  final String paymentId;     // 고유 결제 ID
  final String guideName;     // 결제 대상 가이드 이름
  final int amount;           // 결제 금액
  final DateTime createdAt;   // 결제 시간
  final bool isCanceled;      // 결제 취소 여부

  PaymentHistory({
    required this.paymentId,
    required this.guideName,
    required this.amount,
    required this.createdAt,
    required this.isCanceled,
  });

  // JSON → 객체로 변환
  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      paymentId: json['payment_id'],
      guideName: json['guide_name'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
      isCanceled: json['is_canceled'] ?? false,
    );
  }

  // 객체 → JSON 변환 (필요 시)
  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'guide_name': guideName,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'is_canceled': isCanceled,
    };
  }
}
