import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/plan/plan_model.dart';
import '../../models/plan/plan_list_model.dart';
import '../../models/plan/plan_detail_model.dart';
import '../../models/plan/plan_schedule_model.dart';
import '../../models/plan/plan_schedule_detail_model.dart';
import '../../models/plan/plan_schedule_update_model.dart';
import '../../models/plan/plan_create_request.dart';
import '../../models/plan/plan_update_request.dart';
import '../../models/plan/plan_schedule_create_request.dart';
import '../../models/plan/plan_schedule_update_request.dart';
import '../../models/plan/member_info_response.dart';
import '../../models/plan/add_member_to_plan_request.dart';
import '../../models/plan/add_member_to_plan_response.dart';

/// 계획 API 클래스
/// 백엔드 서버와의 HTTP 통신을 담당합니다.
class PlanApi {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String getApiPrefix(int groupId) => '/api/group/$groupId/plan';

  // 인증 토큰 가져오기 (SharedPreferences에서 직접 가져오도록 수정)
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    // 디버깅을 위해 토큰 존재 여부 출력
    debugPrint('토큰 존재 여부: ${token != null}');
    if (token == null) {
      debugPrint('경고: JWT 토큰이 SharedPreferences에 저장되어 있지 않습니다.');
    }

    return token;
  }

  // 토큰 유효성 검사
  bool _validateToken(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('오류: 인증 토큰이 없습니다. 로그인이 필요합니다.');
      return false;
    }
    return true;
  }

  /// 계획 생성하기
  /// [groupId] 그룹 ID
  /// [request] 계획 생성 요청 데이터
  Future<Plan> createPlan({
    required int groupId,
    required PlanCreateRequest request,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/create');
    debugPrint('API URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 201) {
        return Plan.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '계획 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 그룹의 계획 목록 조회하기
  /// [groupId] 그룹 ID
  Future<List<PlanList>> getPlans(int groupId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => PlanList.fromJson(json)).toList();
      } else {
        throw Exception(
          '계획 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획 상세 정보 조회하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  Future<PlanDetail> getPlanDetail(int groupId, int planId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/$planId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return PlanDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '계획 상세 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획 정보 수정하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [request] 계획 수정 요청 데이터
  Future<Plan> updatePlan({
    required int groupId,
    required int planId,
    required PlanUpdateRequest request,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/update/$planId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Plan.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '계획 수정에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획 삭제하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  Future<void> deletePlan(int groupId, int planId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/delete/$planId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          '계획 삭제에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획-일정 생성하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [request] 일정 생성 요청 데이터
  Future<PlanSchedule> createPlanSchedule({
    required int groupId,
    required int planId,
    required PlanScheduleCreateRequest request,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl${getApiPrefix(groupId)}/$planId/schedule/create',
    );

    // 디버깅을 위한 요청 데이터 출력
    final requestBody = jsonEncode(request.toJson());

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      // 응답 정보 출력
      debugPrint('계획 일정 생성 응답 코드: ${response.statusCode}');

      if (response.statusCode == 201) {
        return PlanSchedule.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '계획 일정 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획-일정 목록 조회하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  Future<List<PlanSchedule>> getPlanSchedules(int groupId, int planId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/$planId/schedule');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => PlanSchedule.fromJson(json)).toList();
      } else {
        throw Exception(
          '계획 일정 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획-일정 상세 조회하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [scheduleId] 일정 ID
  Future<PlanScheduleDetail> getPlanScheduleDetail(
    int groupId,
    int planId,
    int scheduleId,
  ) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl${getApiPrefix(groupId)}/$planId/schedule/$scheduleId',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return PlanScheduleDetail.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '계획 일정 상세 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획-일정 수정하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [scheduleId] 일정 ID
  /// [request] 일정 수정 요청 데이터
  Future<PlanScheduleUpdate> updatePlanSchedule({
    required int groupId,
    required int planId,
    required int scheduleId,
    required PlanScheduleUpdateRequest request,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl${getApiPrefix(groupId)}/$planId/schedule/update/$scheduleId',
    );
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return PlanScheduleUpdate.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '계획 일정 수정에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획-일정 삭제하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [scheduleId] 일정 ID
  Future<void> deletePlanSchedule(
    int groupId,
    int planId,
    int scheduleId,
  ) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl${getApiPrefix(groupId)}/$planId/schedule/delete/$scheduleId',
    );
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          '계획 일정 삭제에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
  
  /// 계획에 추가 가능한 멤버 목록 조회하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID  
  Future<List<MemberInfoResponse>> getAvailableMembers(int groupId, int planId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/$planId/available-members');
    
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => MemberInfoResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          '추가 가능한 멤버 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
  
  /// 계획에 멤버 추가하기
  /// [groupId] 그룹 ID
  /// [planId] 계획 ID
  /// [members] 추가할 멤버 ID 목록
  Future<AddMemberToPlanResponse> addMembersToPlan(
    int groupId, 
    int planId, 
    List<AddMemberToPlanRequest> members
  ) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/$planId/add-member');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(members.map((m) => m.toJson()).toList()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddMemberToPlanResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '계획에 멤버 추가에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
  
  /// 계획에서 나가기
  /// [planId] 계획 ID
  Future<void> leavePlan(int groupId, int planId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl${getApiPrefix(groupId)}/$planId/leave');
    
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          '계획에서 나가기에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
}