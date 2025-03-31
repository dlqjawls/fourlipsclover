import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/plan/plan_model.dart';
import '../models/plan/plan_list_model.dart';
import '../models/plan/plan_detail_model.dart';
import '../models/plan/plan_schedule_model.dart';
import '../models/plan/plan_create_request.dart';
import '../models/plan/plan_update_request.dart';
import '../models/plan/plan_schedule_create_request.dart';
import '../models/plan/plan_schedule_update_model.dart';
import '../models/plan/plan_schedule_update_request.dart';
import '../models/plan/plan_schedule_detail_model.dart';
import '../services/api/plan_api.dart';

class PlanProvider with ChangeNotifier {
  final PlanApi _planApi = PlanApi();

  // 계획 목록
  final Map<int, List<PlanList>> _planLists = {}; // groupId를 키로 사용

  // 현재 선택된 계획
  PlanDetail? _selectedPlanDetail;

  // 계획의 일정 목록
  final Map<int, List<PlanSchedule>> _planSchedules = {}; // planId를 키로 사용

  // 계획별 멤버 수를 캐시하는 맵
  final Map<int, int> _planMemberCounts = {};

  // 계획별 총무 이름을 캐시하는 맵
  final Map<int, String> _planTreasurerNames = {};

  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PlanList> getPlansForGroup(int groupId) => _planLists[groupId] ?? [];
  PlanDetail? get selectedPlanDetail => _selectedPlanDetail;
  List<PlanSchedule> getSchedulesForPlan(int planId) =>
      _planSchedules[planId] ?? [];
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

      // 각 계획의 상세 정보 미리 로드 (멤버 수를 위해)
      for (var plan in plans) {
        // 비동기로 로드하되 응답을 기다리지 않음 - 백그라운드에서 로드
        _prefetchPlanDetails(groupId, plan.planId);
      }

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

  // 계획 상세 정보 미리 가져오기 (멤버 수 표시 위해)
  Future<void> _prefetchPlanDetails(int groupId, int planId) async {
    try {
      final planDetail = await _planApi.getPlanDetail(groupId, planId);

      // 멤버 수 및 총무 이름 캐시 업데이트
      if (planDetail.members != null) {
        _planMemberCounts[planId] = planDetail.members.length;

        // 총무 이름 찾기
        try {
          final treasurerMember = planDetail.members.firstWhere(
            (member) => member.memberId == planDetail.treasurerId,
          );
          _planTreasurerNames[planId] = treasurerMember.nickname;
        } catch (e) {
          _planTreasurerNames[planId] = '총무';
        }
      }

      // selectedPlanDetail 업데이트는 이미 선택된 계획에 대해서만
      if (_selectedPlanDetail?.planId == planId) {
        _selectedPlanDetail = planDetail;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('계획 상세 정보 사전 로드 중 오류: $e');
      // 에러가 발생해도 앱 실행을 계속 유지
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

      // 멤버 수와 총무 이름 캐시 업데이트
      if (planDetail.members != null) {
        _planMemberCounts[planId] = planDetail.members.length;

        try {
          final treasurerMember = planDetail.members.firstWhere(
            (member) => member.memberId == planDetail.treasurerId,
          );
          _planTreasurerNames[planId] = treasurerMember.nickname;
        } catch (e) {
          _planTreasurerNames[planId] = '총무';
        }
      }

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

      // 캐시에서 멤버 수와 총무 이름 제거
      _planMemberCounts.remove(planId);
      _planTreasurerNames.remove(planId);

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
  Future<List<PlanSchedule>> getSchedulesForDate(
    int groupId,
    DateTime date,
  ) async {
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
        final filteredSchedules =
            schedules.where((schedule) {
              final scheduleDate = DateTime(
                schedule.visitAt.year,
                schedule.visitAt.month,
                schedule.visitAt.day,
              );
              final targetDate = DateTime(date.year, date.month, date.day);
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
  debugPrint('일정 생성 시작: $request');
  
  try {
    final newSchedule = await _planApi.createPlanSchedule(
      groupId: groupId,
      planId: planId,
      request: request,
    );
    
    debugPrint('API 호출 성공, 스케줄 ID: ${newSchedule.planScheduleId}');

    // 캐시된 일정 목록 갱신 - 여기서 에러가 발생할 수 있음
    if (_planSchedules.containsKey(planId)) {
      debugPrint('캐시된 일정 목록에 새 일정 추가');
      _planSchedules[planId]!.add(newSchedule);
      notifyListeners(); // 중요: 변경 후 알림
    } else {
      debugPrint('캐시된 일정 목록이 없어 새로 불러오기');
      // 캐시가 없으면 새로 불러옴
      await fetchPlanSchedules(groupId, planId);
    }

    _error = null;
    return newSchedule;
  } catch (e) {
    _error = '일정 생성에 실패했습니다: $e';
    debugPrint(_error);
    throw Exception(_error);
  } finally {
    _setLoading(false);
  }
}

  // 계획 일정 삭제
  Future<void> deletePlanSchedule(
    int groupId,
    int planId,
    int scheduleId,
  ) async {
    _setLoading(true);
    try {
      await _planApi.deletePlanSchedule(groupId, planId, scheduleId);

      // 캐시된 일정 목록에서 삭제
      if (_planSchedules[planId] != null) {
        _planSchedules[planId]!.removeWhere(
          (schedule) => schedule.planScheduleId == scheduleId,
        );
        notifyListeners();
      }

      _error = null;
    } catch (e) {
      _error = '일정 삭제에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // PlanProvider 클래스에 아래 메서드 추가
  Future<PlanScheduleUpdate> updatePlanSchedule({
    required int groupId,
    required int planId,
    required int scheduleId,
    required PlanScheduleUpdateRequest request,
  }) async {
    _setLoading(true);
    try {
      final updatedSchedule = await _planApi.updatePlanSchedule(
        groupId: groupId,
        planId: planId,
        scheduleId: scheduleId,
        request: request,
      );

      // 캐시된 일정 목록 갱신
      if (_planSchedules[planId] != null) {
        // 해당 스케줄을 찾아 업데이트
        final index = _planSchedules[planId]!.indexWhere(
          (schedule) => schedule.planScheduleId == scheduleId,
        );
        if (index != -1) {
          // 업데이트된 정보로 스케줄 객체 생성
          final updatedScheduleObj = PlanSchedule(
            planScheduleId: scheduleId,
            placeName: updatedSchedule.placeName,
            notes: updatedSchedule.notes,
            visitAt: updatedSchedule.visitAt,
          );

          // 기존 스케줄 교체
          _planSchedules[planId]![index] = updatedScheduleObj;
          notifyListeners();
        }
      }

      _error = null;
      return updatedSchedule;
    } catch (e) {
      _error = '일정 수정에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // PlanProvider 클래스에 다음 메서드를 추가합니다

// 계획-일정 상세 조회
Future<PlanScheduleDetail> getPlanScheduleDetail(
  int groupId,
  int planId,
  int scheduleId,
) async {
  _setLoading(true);
  try {
    final scheduleDetail = await _planApi.getPlanScheduleDetail(
      groupId,
      planId,
      scheduleId,
    );
    _error = null;
    return scheduleDetail;
  } catch (e) {
    _error = '일정 상세 정보를 불러오는데 실패했습니다: $e';
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

  // 계획 ID로 총무 닉네임을 가져오는 메서드
  String getTreasurerNickname(int planId) {
    // 캐시된 총무 이름이 있으면 반환
    if (_planTreasurerNames.containsKey(planId)) {
      return _planTreasurerNames[planId]!;
    }

    // 선택된 계획이 해당 계획이라면 총무 이름 찾기
    if (_selectedPlanDetail?.planId == planId &&
        _selectedPlanDetail?.members != null) {
      try {
        final treasurerMember = _selectedPlanDetail!.members.firstWhere(
          (member) => member.memberId == _selectedPlanDetail!.treasurerId,
        );

        // 캐시에 저장하고 반환
        _planTreasurerNames[planId] = treasurerMember.nickname;
        return treasurerMember.nickname;
      } catch (e) {
        debugPrint('총무를 찾을 수 없음: $e');
      }
    }

    // 기본값
    return '총무';
  }

  // 계획 ID로 멤버 수를 가져오는 메서드
  int getPlanMemberCount(int planId) {
    // 디버깅 정보
    debugPrint('getPlanMemberCount 호출: planId=$planId');

    // 캐시된 멤버 수가 있으면 반환
    if (_planMemberCounts.containsKey(planId)) {
      final count = _planMemberCounts[planId]!;
      debugPrint('캐시된 멤버 수 반환: $count');
      return count;
    }

    debugPrint('_selectedPlanDetail 존재 여부: ${_selectedPlanDetail != null}');

    // 선택된 계획이 해당 계획이라면 멤버 수 반환
    if (_selectedPlanDetail?.planId == planId &&
        _selectedPlanDetail?.members != null) {
      final count = _selectedPlanDetail!.members.length;
      debugPrint('selectedPlanDetail에서 멤버 수 찾음: $count');

      // 캐시에 저장
      _planMemberCounts[planId] = count;
      return count;
    }

    debugPrint('일치하는 계획을 찾을 수 없어 0 반환');
    return 0;
  }

  // 로딩 상태 직접 설정 (공통화)
  void setLoading(bool loading) {
    _setLoading(loading);
  }
}
