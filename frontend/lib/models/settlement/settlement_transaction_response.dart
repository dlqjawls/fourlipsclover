// lib/models/settlement/settlement_transaction_response.dart
import 'transaction_types.dart';

class SettlementMemberResponse {
  final int memberId;
  final String? name;
  final String? nickname;
  final String? profileImageUrl;

  SettlementMemberResponse({
    required this.memberId,
    this.name,
    this.nickname,
    this.profileImageUrl,
  });

  factory SettlementMemberResponse.fromJson(Map<String, dynamic> json) {
    return SettlementMemberResponse(
      memberId: json['memberId'],
      name: json['name'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

class SettlementTransactionResponse {
  final int settlementTransactionId;
  final int cost;
  final SettlementMemberResponse payee; // 수취인
  final SettlementMemberResponse payer; // 송금자
  final TransactionStatus transactionStatus;
  final DateTime? createdAt;
  final DateTime? sentAt;

  SettlementTransactionResponse({
    required this.settlementTransactionId,
    required this.cost,
    required this.payee,
    required this.payer,
    required this.transactionStatus,
    this.createdAt,
    this.sentAt,
  });

  factory SettlementTransactionResponse.fromJson(Map<String, dynamic> json) {
    return SettlementTransactionResponse(
      settlementTransactionId: json['settlementTransactionId'],
      cost: json['cost'],
      payee: SettlementMemberResponse.fromJson(json['payee']),
      payer: SettlementMemberResponse.fromJson(json['payer']),
      transactionStatus: _parseTransactionStatus(json['transactionStatus']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
    );
  }

  // PENDING, COMPLETED 등의 문자열을 enum으로 변환
  static TransactionStatus _parseTransactionStatus(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => TransactionStatus.PENDING,
    );
  }
}

