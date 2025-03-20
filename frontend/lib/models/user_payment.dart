class Payment {
  final String id;
  final int amount;
  final DateTime date;
  final String description;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
