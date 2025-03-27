import 'package:flutter/foundation.dart';
import '../services/api/plan_api.dart';
import '../models/plan/plan_model.dart';
import '../models/plan/plan_list_model.dart';
import '../models/plan/plan_detail_model.dart';
import '../models/plan/plan_schedule_model.dart';
import '../models/plan/plan_create_request.dart';
import '../models/plan/plan_update_request.dart';
import '../models/plan/plan_schedule_create_request.dart';
import '../models/plan/plan_schedule_update_request.dart';

class PlanProvider with ChangeNotifier {
  final PlanApi _planApi = PlanApi();
  
  // 계획 목록 캐시
  Map<int, List<PlanList>> _planListCache = {}; // 그룹별 계획 목록
  Map<int, PlanDetail> _planDetailCache = {}; // 계획 상세 정보
  Map<String, List<PlanSchedule>> _scheduleCache = {}; // planId별 일정 목록
  
  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 에러 메시지
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 특정 그룹의 여행 계획 목록 가져오기 (API 호출)
  Future<List<PlanList>> fetchPlansForGroup(int groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final plans = await _planApi.getPlans(groupId);
      _planListCache[groupId] = plans;
      _isLoading = false;
      notifyListeners();
      return plans;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '계획 목록을 불러오는데 실패했습니다: $e';
      notifyListeners();
      return [];
    }
  }
  
  // 캐시에서 그룹의 계획 목록 가져오기 (없으면 API 호출)
  Future<List<PlanList>> getPlansForGroup(int groupId) async {
    if (_planListCache.containsKey(groupId)) {
      return _planListCache[groupId]!;
    } else {
      return await fetchPlansForGroup(groupId);
    }
  }
  
  // 계획 상세 정보 가져오기 (API 호출)
  Future<PlanDetail?> fetchPlanDetail(int groupId, int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final planDetail = await _planApi.getPlanDetail(groupId, planId);
      _planDetailCache[planId] = planDetail;
      _isLoading = false;
      notifyListeners();
      return planDetail;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '계획 상세 정보를 불러오는데 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }
  
  // 계획 생성하기
  Future<Plan?> createPlan({
    required int groupId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<int> members,
    required int treasurerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = PlanCreateRequest(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        members: members,
        treasurerId: treasurerId,
      );
      
      final createdPlan = await _planApi.createPlan(
        groupId: groupId,
        request: request,
      );
      
      // 캐시 무효화
      _planListCache.remove(groupId);
      
      _isLoading = false;
      notifyListeners();
      return createdPlan;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '계획 생성에 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }
  
  // 계획 수정하기
  Future<Plan?> updatePlan({
    required int groupId,
    required int planId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = PlanUpdateRequest(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );
      
      final updatedPlan = await _planApi.updatePlan(
        groupId: groupId,
        planId: planId,
        request: request,
      );
      
      // 캐시 무효화
      _planListCache.remove(groupId);
      _planDetailCache.remove(planId);
      
      _isLoading = false;
      notifyListeners();
      return updatedPlan;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '계획 수정에 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }
  
  // 계획 삭제하기
  Future<bool> deletePlan(int groupId, int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _planApi.deletePlan(groupId, planId);
      
      // 캐시 무효화
      _planListCache.remove(groupId);
      _planDetailCache.remove(planId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '계획 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }
  
  // 계획 일정 목록 가져오기
  Future<List<PlanSchedule>> fetchSchedulesForPlan(int groupId, int planId) async {
    final cacheKey = '$groupId-$planId';
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final schedules = await _planApi.getPlanSchedules(groupId, planId);
      _scheduleCache[cacheKey] = schedules;
      _isLoading = false;
      notifyListeners();
      return schedules;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '일정 목록을 불러오는데 실패했습니다: $e';
      notifyListeners();
      return [];
    }
  }
  
  // 계획 일정 생성하기
  Future<PlanSchedule?> createSchedule({
    required int groupId,
    required int planId,
    required int restaurantId,
    String? notes,
    required DateTime visitAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = PlanScheduleCreateRequest(
        restaurantId: restaurantId,
        notes: notes,
        visitAt: visitAt,
      );
      
      final createdSchedule = await _planApi.createPlanSchedule(
        groupId: groupId,
        planId: planId,
        request: request,
      );
      
      // 캐시 무효화
      final cacheKey = '$groupId-$planId';
      _scheduleCache.remove(cacheKey);
      
      _isLoading = false;
      notifyListeners();
      return createdSchedule;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '일정 생성에 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }
  
  // 계획 일정 수정하기
  Future<bool> updateSchedule({
    required int groupId,
    required int planId,
    required int scheduleId,
    int? restaurantId,
    String? notes,
    required DateTime visitAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = PlanScheduleUpdateRequest(
        restaurantId: restaurantId,
        notes: notes,
        visitAt: visitAt,
      );
      
      await _planApi.updatePlanSchedule(
        groupId: groupId,
        planId: planId,
        scheduleId: scheduleId,
        request: request,
      );
      
      // 캐시 무효화
      final cacheKey = '$groupId-$planId';
      _scheduleCache.remove(cacheKey);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '일정 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }
  
  // 계획 일정 삭제하기
  Future<bool> deleteSchedule(int groupId, int planId, int scheduleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _planApi.deletePlanSchedule(groupId, planId, scheduleId);
      
      // 캐시 무효화
      final cacheKey = '$groupId-$planId';
      _scheduleCache.remove(cacheKey);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '일정 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }
  
  // 특정 날짜에 여행 계획이 있는지 확인
  Future<bool> hasPlansOnDate(int groupId, DateTime date) async {
    final plans = await getPlansForGroup(groupId);
    return plans.any((plan) => 
      (date.isAfter(plan.startDate) || date.isAtSameMomentAs(plan.startDate)) && 
      (date.isBefore(plan.endDate) || date.isAtSameMomentAs(plan.endDate))
    );
  }
  
  // 특정 날짜의 여행 계획 목록 반환
  Future<List<PlanList>> getPlansForDate(int groupId, DateTime date) async {
    final plans = await getPlansForGroup(groupId);
    return plans.where((plan) => 
      (date.isAfter(plan.startDate) || date.isAtSameMomentAs(plan.startDate)) && 
      (date.isBefore(plan.endDate) || date.isAtSameMomentAs(plan.endDate))
    ).toList();
  }
  
  // 특정 날짜의 세부 일정 목록 반환
  Future<List<PlanSchedule>> getSchedulesForDate(int groupId, DateTime date) async {
    final result = <PlanSchedule>[];
    final plans = await getPlansForDate(groupId, date);
    
    for (var plan in plans) {
      final cacheKey = '$groupId-${plan.planId}';
      List<PlanSchedule> schedules;
      
      if (_scheduleCache.containsKey(cacheKey)) {
        schedules = _scheduleCache[cacheKey]!;
      } else {
        schedules = await fetchSchedulesForPlan(groupId, plan.planId);
      }
      
      if (schedules.isNotEmpty) {
        result.addAll(schedules.where((schedule) => 
          schedule.visitAt.year == date.year && 
          schedule.visitAt.month == date.month && 
          schedule.visitAt.day == date.day
        ));
      }
    }
    
    return result;
  }
  
  // 캐시 초기화
  void clearCache() {
    _planListCache.clear();
    _planDetailCache.clear();
    _scheduleCache.clear();
    notifyListeners();
  }
}