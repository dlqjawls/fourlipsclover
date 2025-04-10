// lib/models/settlement/settlement_request_model.dart
import 'transaction_types.dart';

class SettlementRequest {
  final int settlementId;
  final String planTitle;
  final TreasurerInfo treasurer;
  final List<SettlementTransaction> transactions;
  final DateTime requestedDate;

  SettlementRequest({
    required this.settlementId,
    required this.planTitle,
    required this.treasurer,
    required this.transactions,
    required this.requestedDate,
  });

  factory SettlementRequest.fromJson(Map<String, dynamic> json) {
    return SettlementRequest(
      settlementId: json['settlementId'],
      planTitle: json['planTitle'],
      treasurer: TreasurerInfo.fromJson(json['treasurer']),
      transactions:
          (json['settlementTransactionResponses'] as List)
              .map((transaction) => SettlementTransaction.fromJson(transaction))
              .toList(),
      requestedDate: DateTime.parse(json['requestedDate']),
    );
  }

  // 총 정산 금액
  int get totalAmount {
    return transactions.fold(0, (sum, transaction) => sum + transaction.cost);
  }

  // 정산 요청 날짜 포맷팅
  String get formattedRequestDate {
    return '${requestedDate.year}년 ${requestedDate.month}월 ${requestedDate.day}일';
  }
}

class TreasurerInfo {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl;

  TreasurerInfo({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
  });

  factory TreasurerInfo.fromJson(Map<String, dynamic> json) {
    return TreasurerInfo(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
    );
  }
}

class SettlementTransaction {
  final int settlementTransactionId;
  final int cost;
  final MemberInfo payee; // 수취인 (받는 사람)
  final MemberInfo payer; // 송금자 (보내는 사람)
  final TransactionStatus transactionStatus;
  final DateTime createdAt;
  final DateTime? sentAt;

  SettlementTransaction({
    required this.settlementTransactionId,
    required this.cost,
    required this.payee,
    required this.payer,
    required this.transactionStatus,
    required this.createdAt,
    this.sentAt,
  });

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) {
    return SettlementTransaction(
      settlementTransactionId: json['settlementTransactionId'],
      cost: json['cost'],
      payee: MemberInfo.fromJson(json['payee']),
      payer: MemberInfo.fromJson(json['payer']),
      transactionStatus: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['transactionStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
    );
  }
}

class MemberInfo {
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl;

  MemberInfo({
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
    );
  }
}
