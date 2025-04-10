// lib/models/settlement/settlement_situation_model.dart
import 'package:frontend/models/settlement/settlement_model.dart';
import 'package:frontend/models/settlement/settlement_transaction_response.dart';

class SettlementSituationResponse {
  final int settlementId;
  final String planName;
  final int planId;
  final String treasurerName;
  final int treasurerId;
  final SettlementStatus settlementStatus;
  final DateTime startDate;
  final DateTime endDate;
  final List<SettlementTransactionResponse> settlementTransactionResponses;

  SettlementSituationResponse({
    required this.settlementId,
    required this.planName,
    required this.planId,
    required this.treasurerName,
    required this.treasurerId,
    required this.settlementStatus,
    required this.startDate,
    required this.endDate,
    required this.settlementTransactionResponses,
  });

  factory SettlementSituationResponse.fromJson(Map<String, dynamic> json) {
    return SettlementSituationResponse(
      settlementId: json['settlementId'],
      planName: json['planName'],
      planId: json['planId'],
      treasurerName: json['treasurerName'],
      treasurerId: json['treasurerId'],
      settlementStatus: _parseSettlementStatus(json['settlementStatus']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      settlementTransactionResponses: (json['settlementTransactionResponses'] as List)
          .map((e) => SettlementTransactionResponse.fromJson(e))
          .toList(),
    );
  }

  get transactions => null;

  // PENDING, IN_PROGRESS, COMPLETED, CANCELLED 등의 문자열을 enum으로 변환
  static SettlementStatus _parseSettlementStatus(String status) {
    return SettlementStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => SettlementStatus.PENDING,
    );
  }
}