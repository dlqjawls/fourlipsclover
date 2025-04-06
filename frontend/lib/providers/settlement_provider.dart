// lib/providers/settlement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/settlement/settlement_model.dart';
import '../models/settlement/settlement_request_model.dart';
import '../models/settlement/update_participant_model.dart';
import '../services/api/settlement_api.dart';

class SettlementProvider with ChangeNotifier {
  final SettlementApi _settlementApi = SettlementApi();
  
  // 정산 상세 정보 캐시
  Map<int, Settlement> _settlementCache = {};
  
  // 정산 요청 캐시
  Map<int, SettlementRequest> _settlementRequestCache = {};
  
  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Settlement? getSettlementForPlan(int planId) => _settlementCache[planId];
  SettlementRequest? getSettlementRequestForPlan(int planId) => _settlementRequestCache[planId];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 로딩 상태 설정
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
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
      
      // 성공 후 상세 정보 바로 로드
      await fetchSettlementDetail(planId);
      
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
      
      // 캐시 업데이트
      _settlementRequestCache[planId] = request;
      
      _error = null;
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
  
  // 정산 참여자 업데이트
  Future<bool> updateParticipants(int expenseId, List<int> memberIds) async {
    setLoading(true);
    try {
      final response = await _settlementApi.updateParticipants(expenseId, memberIds);
      
      // 정산 정보 다시 불러오기 (영향을 받은 모든 planId에 대해)
      for (var planId in _settlementCache.keys) {
        final settlement = _settlementCache[planId];
        if (settlement != null) {
          for (var expense in settlement.expenses) {
            if (expense.expenseId == expenseId) {
              await fetchSettlementDetail(planId);
              break;
            }
          }
        }
      }
      
      _error = null;
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
      case SettlementStatus.COMPLETED:
        return '완료됨';
      case SettlementStatus.CANCELLED:
        return '취소됨';
    }
  }
}