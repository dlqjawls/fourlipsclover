import 'package:flutter/foundation.dart';
import '../models/plan/plan_model.dart';
import '../models/plan/plan_list_model.dart';
import '../models/plan/plan_detail_model.dart';
import '../models/plan/plan_schedule_model.dart';
import '../models/plan/plan_create_request.dart';
import '../models/plan/plan_update_request.dart';
import '../models/plan/plan_schedule_create_request.dart';
import '../services/api/plan_api.dart';
import 'package:flutter/widgets.dart';

class PlanProvider with ChangeNotifier {
  final PlanApi _planApi = PlanApi();
  
  // 계획 목록
  final Map<int, List<PlanList>> _planLists = {}; // groupId를 키로 사용
  
  // 현재 선택된 계획
  PlanDetail? _selectedPlanDetail;
  
  // 계획의 일정 목록
  final Map<int, List<PlanSchedule>> _planSchedules = {}; // planId를 키로 사용
  
  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<PlanList> getPlansForGroup(int groupId) => _planLists[groupId] ?? [];
  PlanDetail? get selectedPlanDetail => _selectedPlanDetail;
  List<PlanSchedule> getSchedulesForPlan(int planId) => _planSchedules[planId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 계획 생성
  Future<Plan> createPlan({
    required int groupId,
    required PlanCreateRequest request,
  }) async {
    _setLoading(true);
    try {
      final newPlan = await _planApi.createPlan(
        groupId: groupId,
        request: request,
      );
      
      // 캐시된 계획 목록 갱신을 위해 다시 로드
      await fetchPlans(groupId);
      
      _error = null;
      return newPlan;
    } catch (e) {
      _error = '계획 생성에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // 그룹의 계획 목록 조회
  Future<List<PlanList>> fetchPlans(int groupId) async {
    _setLoading(true);
    try {
      final plans = await _planApi.getPlans(groupId);
      _planLists[groupId] = plans;
      _error = null;
      notifyListeners();
      return plans;
    } catch (e) {
      _error = '계획 목록을 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // 특정 날짜의 계획 조회 (캘린더용)
  Future<List<PlanList>> getPlansForDate(int groupId, DateTime date) async {
    try {
      // 아직 해당 그룹의 계획이 캐시되어 있지 않으면 로드
      if (_planLists[groupId] == null) {
        await fetchPlans(groupId);
      }
      
      // 이 날짜가 속한 계획 필터링
      return (_planLists[groupId] ?? []).where((plan) {
        // 날짜가 계획 시작일부터 종료일 사이인지 확인
        return !date.isBefore(plan.startDate) && 
               !date.isAfter(plan.endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      _error = '날짜별 계획을 조회하는데 실패했습니다: $e';
      debugPrint(_error);
      return [];
    }
  }
  
  // 계획 상세 정보 조회
  Future<PlanDetail> fetchPlanDetail(int groupId, int planId) async {
    _setLoading(true);
    try {
      final planDetail = await _planApi.getPlanDetail(groupId, planId);
      _selectedPlanDetail = planDetail;
      _error = null;
      notifyListeners();
      return planDetail;
    } catch (e) {
      _error = '계획 상세 정보를 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // 계획 수정
  Future<Plan> updatePlan({
    required int groupId,
    required int planId,
    required PlanUpdateRequest request,
  }) async {
    _setLoading(true);
    try {
      final updatedPlan = await _planApi.updatePlan(
        groupId: groupId,
        planId: planId,
        request: request,
      );
      
      // 캐시된 계획 목록 갱신을 위해 다시 로드
      await fetchPlans(groupId);
      
      // 선택된 계획이 수정된 계획이라면 상세 정보도 갱신
      if (_selectedPlanDetail?.planId == planId) {
        await fetchPlanDetail(groupId, planId);
      }
      
      _error = null;
      return updatedPlan;
    } catch (e) {
      _error = '계획 수정에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // 계획 삭제
  Future<void> deletePlan(int groupId, int planId) async {
    _setLoading(true);
    try {
      await _planApi.deletePlan(groupId, planId);
      
      // 캐시된 계획 목록에서도 삭제
      if (_planLists[groupId] != null) {
        _planLists[groupId]!.removeWhere((plan) => plan.planId == planId);
      }
      
      // 선택된 계획이 삭제된 계획이라면 선택 해제
      if (_selectedPlanDetail?.planId == planId) {
        _selectedPlanDetail = null;
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '계획 삭제에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // 특정 날짜의 일정 조회 
Future<List<PlanSchedule>> getSchedulesForDate(int groupId, DateTime date) async {
  try {
    // 먼저 해당 날짜에 속하는 계획 목록 가져오기
    final plansForDate = await getPlansForDate(groupId, date);
    
    // 모든 계획의 일정을 담을 리스트
    List<PlanSchedule> schedulesForDate = [];
    
    // 각 계획의 일정 로드 및 필터링
    for (var plan in plansForDate) {
      // 아직 일정이 로드되지 않았다면 로드
      if (_planSchedules[plan.planId] == null) {
        await fetchPlanSchedules(groupId, plan.planId);
      }
      
      // 이 계획의 일정 가져오기
      final schedules = _planSchedules[plan.planId] ?? [];
      
      // 해당 날짜에 속하는 일정만 필터링
      final filteredSchedules = schedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.visitAt.year,
          schedule.visitAt.month,
          schedule.visitAt.day,
        );
        final targetDate = DateTime(
          date.year,
          date.month,
          date.day,
        );
        return scheduleDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      schedulesForDate.addAll(filteredSchedules);
    }
    
    // 방문 시간순으로 정렬
    schedulesForDate.sort((a, b) => a.visitAt.compareTo(b.visitAt));
    
    return schedulesForDate;
  } catch (e) {
    _error = '날짜별 일정을 조회하는데 실패했습니다: $e';
    debugPrint(_error);
    return [];
  }
}
  
  // 계획의 일정 목록 조회
  Future<List<PlanSchedule>> fetchPlanSchedules(int groupId, int planId) async {
    _setLoading(true);
    try {
      final schedules = await _planApi.getPlanSchedules(groupId, planId);
      _planSchedules[planId] = schedules;
      _error = null;
      notifyListeners();
      return schedules;
    } catch (e) {
      _error = '계획 일정 목록을 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // 계획 일정 생성
  Future<PlanSchedule> createPlanSchedule({
    required int groupId,
    required int planId,
    required PlanScheduleCreateRequest request,
  }) async {
    _setLoading(true);
    try {
      final newSchedule = await _planApi.createPlanSchedule(
        groupId: groupId,
        planId: planId,
        request: request,
      );
      
      // 캐시된 일정 목록 갱신
      if (_planSchedules[planId] != null) {
        _planSchedules[planId]!.add(newSchedule);
      } else {
        await fetchPlanSchedules(groupId, planId);
      }
      
      _error = null;
      notifyListeners();
      return newSchedule;
    } catch (e) {
      _error = '일정 생성에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }
  
void _setLoading(bool loading) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  });
}
  
  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}