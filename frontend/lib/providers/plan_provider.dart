// providers/plan_provider.dart
import 'package:flutter/foundation.dart';
import '../models/plan_model.dart';

class PlanProvider with ChangeNotifier {
  List<Plan> _plans = [];
  
  // 특정 그룹의 여행 계획 목록 반환
  List<Plan> getPlansForGroup(int groupId) {
    return _plans.where((plan) => plan.groupId == groupId).toList();
  }
  
  // 여행 계획 추가
  void addPlan(Plan plan) {
    _plans.add(plan);
    notifyListeners();
  }
  
  // 여행 계획 삭제
  void deletePlan(int planId) {
    _plans.removeWhere((plan) => plan.planId == planId);
    notifyListeners();
  }
  
  // 특정 날짜에 여행 계획이 있는지 확인
  bool hasPlansOnDate(int groupId, DateTime date) {
    final plans = getPlansForGroup(groupId);
    return plans.any((plan) => 
      (date.isAfter(plan.startDate) || date.isAtSameMomentAs(plan.startDate)) && 
      (date.isBefore(plan.endDate) || date.isAtSameMomentAs(plan.endDate))
    );
  }
  
  // 특정 날짜의 여행 계획 목록 반환
  List<Plan> getPlansForDate(int groupId, DateTime date) {
    final plans = getPlansForGroup(groupId);
    return plans.where((plan) => 
      (date.isAfter(plan.startDate) || date.isAtSameMomentAs(plan.startDate)) && 
      (date.isBefore(plan.endDate) || date.isAtSameMomentAs(plan.endDate))
    ).toList();
  }
  
  // 특정 날짜의 세부 일정 목록 반환
  List<PlanPlace> getPlanPlacesForDate(int groupId, DateTime date) {
    final result = <PlanPlace>[];
    final plans = getPlansForDate(groupId, date);
    
    for (var plan in plans) {
      if (plan.planPlaces.isNotEmpty) {
        result.addAll(plan.planPlaces.where((pp) => 
          pp.visitAt.year == date.year && 
          pp.visitAt.month == date.month && 
          pp.visitAt.day == date.day
        ));
      }
    }
    
    return result;
  }
}