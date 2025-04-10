// lib/providers/settlement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/settlement/settlement_model.dart';
import '../models/settlement/settlement_request_model.dart';
import '../models/settlement/settlement_situation_model.dart';
import '../models/settlement/settlement_transaction_response.dart';
import '../models/settlement/update_participant_model.dart';
import '../services/api/settlement_api.dart';
import '../models/settlement/transaction_types.dart';
import 'dart:convert';

class SettlementProvider with ChangeNotifier {
  final SettlementApi _settlementApi = SettlementApi();

  // 정산 상세 정보 캐시
  Map<int, Settlement> _settlementCache = {};

  // 정산 요청 캐시
  Map<int, SettlementRequest> _settlementRequestCache = {};

  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;

  // 데이터 변경 추적 플래그
  bool _dataChanged = false;

  // Getters
  Settlement? getSettlementForPlan(int planId) => _settlementCache[planId];
  SettlementRequest? getSettlementRequestForPlan(int planId) =>
      _settlementRequestCache[planId];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDataChanged => _dataChanged;

  // 로딩 상태 설정
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // 데이터 변경 상태 설정
  void setDataChanged(bool value) {
    _dataChanged = value;
    notifyListeners();
  }

  // 데이터 변경 플래그 리셋
  void resetDataChangedFlag() {
    _dataChanged = false;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 정산 생성
  Future<bool> createSettlement(int planId) async {
    setLoading(true);
    try {
      await _settlementApi.createSettlement(planId);
      _error = null;
      setDataChanged(true);
      return true;
    } catch (e) {
      _error = '정산 생성에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 정산 상세 정보 조회
  Future<Settlement?> fetchSettlementDetail(int planId) async {
    setLoading(true);
    try {
      final settlement = await _settlementApi.getSettlementDetail(planId);
      debugPrint('정산 상세 정보 조회 성공: planId=$planId');

      // 캐시 업데이트
      _settlementCache[planId] = settlement;
      _error = null;
      notifyListeners();
      return settlement;
    } catch (e) {
      _error = '정산 정보를 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      return null;
    } finally {
      setLoading(false);
    }
  }

  // 정산 요청
  Future<SettlementRequest?> requestSettlement(int planId) async {
    setLoading(true);
    try {
      final request = await _settlementApi.requestSettlement(planId);
      debugPrint('정산 요청 성공: planId=$planId');

      // 캐시 업데이트
      _settlementRequestCache[planId] = request;

      _error = null;
      setDataChanged(true);
      notifyListeners();
      return request;
    } catch (e) {
      _error = '정산 요청에 실패했습니다: $e';
      debugPrint(_error);
      return null;
    } finally {
      setLoading(false);
    }
  }

  // 정산 참여자 업데이트 (개선 버전)
  Future<bool> updateParticipants(int expenseId, List<int> memberIds) async {
    setLoading(true);

    try {
      debugPrint('정산 참여자 업데이트 시작: expenseId=$expenseId, memberIds=$memberIds');

      // API 요청 시작
      final response = await _settlementApi.updateParticipants(
        expenseId,
        memberIds,
      );

      debugPrint('정산 참여자 업데이트 응답: ${jsonEncode(response)}');

      // 참여자 업데이트에 영향을 받는 planId 찾기
      int? affectedPlanId;

      // 정산 캐시에서 해당 expense가 포함된 plan 찾기
      for (var entry in _settlementCache.entries) {
        final planId = entry.key;
        final settlement = entry.value;

        bool containsExpense = settlement.expenses.any(
          (expense) => expense.expenseId == expenseId,
        );

        if (containsExpense) {
          affectedPlanId = planId;
          debugPrint('영향을 받는 planId 발견: $planId');
          break;
        }
      }

      // 찾은 planId에 대해 정산 정보 갱신
      if (affectedPlanId != null) {
        debugPrint('정산 정보 갱신 시작: planId=$affectedPlanId');
        await fetchSettlementDetail(affectedPlanId);
      } else {
        debugPrint('경고: 영향을 받는 planId를 찾을 수 없음');
      }

      _error = null;
      setDataChanged(true);
      notifyListeners(); // 상태 변경 알림 추가
      return true;
    } catch (e) {
      _error = '정산 참여자 업데이트에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 총 정산 금액 계산 (특정 정산에 대해)
  int calculateTotalAmount(int planId) {
    final settlement = _settlementCache[planId];
    if (settlement == null) return 0;

    return settlement.totalAmount;
  }

  // 멤버별 정산 금액 계산 (특정 정산에 대해)
  Map<int, int> calculateMemberAmounts(int planId) {
    final settlement = _settlementCache[planId];
    if (settlement == null) return {};

    return settlement.getMemberPayments();
  }

  // 청구 가능 여부 확인
  bool canRequestSettlement(int planId) {
    final settlement = _settlementCache[planId];
    if (settlement == null) return false;

    // 결제 내역이 있는지 확인
    return settlement.expenses.isNotEmpty;
  }

  // 정산 상태 텍스트 가져오기
  String getSettlementStatusText(SettlementStatus status) {
    switch (status) {
      case SettlementStatus.PENDING:
        return '진행 중';
      case SettlementStatus.IN_PROGRESS:
        return '정산 요청됨';
      case SettlementStatus.COMPLETED:
        return '완료됨';
      case SettlementStatus.CANCELED:
        return '취소됨';
      default:
        return '알 수 없음';
    }
  }

  // 정산 상황 캐시
  Map<int, List<SettlementSituationResponse>> _settlementSituationCache = {};

  // 정산 상황 Getter
  List<SettlementSituationResponse>? getSettlementSituationForPlan(
    int planId
  ) => _settlementSituationCache[planId];

  // 정산 상황 조회
  Future<List<SettlementSituationResponse>?> fetchSettlementSituation(
    int planId,
  ) async {
    setLoading(true);
    try {
      debugPrint('정산 현황 조회 API 호출: planId=$planId');
      final situations = await _settlementApi.getSettlementSituation(planId);
      debugPrint('정산 현황 조회 성공: planId=$planId, 건수=${situations.length}');

      _settlementSituationCache[planId] = situations;
      _error = null;
      notifyListeners();
      return situations;
    } on FormatException catch (e) {
      debugPrint('파싱 오류 발생: $e');
      throw e;
    } catch (e, stackTrace) {
      _error = '정산 현황을 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      debugPrint('스택 트레이스: $stackTrace');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // 정산 거래 완료 처리
  Future<bool> completeTransaction(int planId, int transactionId) async {
    setLoading(true);
    try {
      debugPrint(
        '정산 거래 완료 처리 시작: planId=$planId, transactionId=$transactionId',
      );

      final result = await _settlementApi.completeTransaction(
        planId,
        transactionId,
      );

      debugPrint('정산 거래 완료 처리 결과: $result');

      // 정산 상황 다시 로드
      await fetchSettlementSituation(planId);

      // 결과가 COMPLETED면 정산이 완료된 것이므로 결제 상세 정보도 갱신
      if (result == "COMPLETED") {
        await fetchSettlementDetail(planId);
      }

      // 데이터 변경 플래그 설정
      setDataChanged(true);

      _error = null;
      return true;
    } catch (e) {
      _error = '정산 거래 완료 처리에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 정산 상태 텍스트 가져오기
  String getTransactionStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.PENDING:
        return '대기 중';
      case TransactionStatus.COMPLETED:
        return '완료됨';
      case TransactionStatus.FAILED:
        return '실패함';
      case TransactionStatus.CANCELED:
        return '취소됨';
      default:
        return '알 수 없음';
    }
  }
}