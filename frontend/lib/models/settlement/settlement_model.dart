// lib/models/settlement/settlement_model.dart
import 'package:intl/intl.dart';

enum SettlementStatus {
  PENDING,     // 진행 중
  IN_PROGRESS, // 정산 요청됨
  COMPLETED,   // 완료됨
  CANCELED    // 취소됨
}

class Settlement {
  final int settlementId;
  final String planName;
  final int planId;
  final String treasurerName;
  final int treasurerId;
  final SettlementStatus settlementStatus;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Expense> expenses;

  Settlement({
    required this.settlementId,
    required this.planName,
    required this.planId,
    required this.treasurerName,
    required this.treasurerId,
    required this.settlementStatus,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    required this.expenses,
  });

  // 결제 내역 총액
  int get totalAmount {
    return expenses.fold(0, (sum, expense) => sum + expense.totalPayment);
  }

  // 멤버별 지불해야 할 금액
  Map<int, int> getMemberPayments() {
    Map<int, int> memberCosts = {};
    
    for (var expense in expenses) {
      final participantCount = expense.expenseParticipants.length;
      if (participantCount == 0) continue;
      
      final costPerPerson = (expense.totalPayment / participantCount).ceil();
      
      for (var participant in expense.expenseParticipants) {
        final memberId = participant.memberId;
        memberCosts[memberId] = (memberCosts[memberId] ?? 0) + costPerPerson;
      }
    }
    
    return memberCosts;
  }

  // 결제 기간 포맷팅
  String getFormattedPeriod() {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    return '${dateFormat.format(startDate)} ~ ${dateFormat.format(endDate)}';
  }

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'settlementId': settlementId,
      'planName': planName,
      'planId': planId,
      'treasurerName': treasurerName,
      'treasurerId': treasurerId,
      'settlementStatus': settlementStatus.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'expenseResponses': expenses.map((expense) => expense.toJson()).toList(),
    };
  }

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      settlementId: json['settlementId'],
      planName: json['planName'],
      planId: json['planId'],
      treasurerName: json['treasurerName'],
      treasurerId: json['treasurerId'],
      settlementStatus: SettlementStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['settlementStatus']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      expenses: (json['expenseResponses'] as List)
          .map((expense) => Expense.fromJson(expense))
          .toList(),
    );
  }
}

class Expense {
  final int expenseId;
  final int paymentApprovalId;
  final int totalPayment;
  final DateTime approvedAt;
  final List<ExpenseParticipant> expenseParticipants;

  Expense({
    required this.expenseId,
    required this.paymentApprovalId,
    required this.totalPayment,
    required this.approvedAt,
    required this.expenseParticipants,
  });

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'paymentApprovalId': paymentApprovalId,
      'totalPayment': totalPayment,
      'approvedAt': approvedAt.toIso8601String(),
      'expenseParticipants': expenseParticipants.map((participant) => participant.toJson()).toList(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'],
      paymentApprovalId: json['paymentApprovalId'],
      totalPayment: json['totalPayment'],
      approvedAt: DateTime.parse(json['approvedAt']),
      expenseParticipants: (json['expenseParticipants'] as List)
          .map((participant) => ExpenseParticipant.fromJson(participant))
          .toList(),
    );
  }

  // 참여자당 지불 금액
  int get amountPerPerson {
    if (expenseParticipants.isEmpty) return 0;
    return (totalPayment / expenseParticipants.length).ceil();
  }

  // 결제일 포맷팅
  String getFormattedDate() {
    return DateFormat('yyyy년 MM월 dd일 HH:mm').format(approvedAt);
  }
}

class ExpenseParticipant {
  final int expenseParticipantId;
  final int memberId;
  final String email;
  final String nickname;
  final String? profileUrl;

  ExpenseParticipant({
    required this.expenseParticipantId,
    required this.memberId,
    required this.email,
    required this.nickname,
    this.profileUrl,
  });

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'expenseParticipantId': expenseParticipantId,
      'memberId': memberId,
      'email': email,
      'nickname': nickname,
      'profileUrl': profileUrl,
    };
  }

  factory ExpenseParticipant.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipant(
      expenseParticipantId: json['expenseParticipantId'],
      memberId: json['memberId'],
      email: json['email'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
    );
  }
}