import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/group/group_model.dart';
import '../../models/group/group_detail_model.dart';
import '../../models/group/group_invitation_model.dart';
import '../../models/group/group_join_request_model.dart';
import 'api_util.dart';

/// 그룹 API 클래스
/// 백엔드 서버와의 HTTP 통신을 담당합니다.
class GroupApi {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/group';

  // 인증 토큰 가져오기 (ApiUtil 사용)
  Future<String?> _getAuthToken() async {
    return await ApiUtil.getJwtToken();
  }

  // 토큰 유효성 검사 (ApiUtil 사용)
  bool _validateToken(String? token) {
    return ApiUtil.validateToken(token);
  }

  /// 그룹 생성하기
  /// [name] 그룹 이름
  /// [description] 그룹 설명
  /// [isPublic] 공개 여부
  Future<Group> createGroup({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    debugPrint('인증 토큰: $token');

    final url = Uri.parse('$baseUrl$apiPrefix');
    debugPrint('API URL: $url');

    final requestBody = {
      'name': name,
      'description': description,
      'isPublic': isPublic,
    };
    debugPrint('요청 데이터: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('응답 코드: ${response.statusCode}');
      debugPrint('응답 본문: ${response.body}');

      if (response.statusCode == 201) {
        return Group.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '그룹 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 그룹 초대 URL 생성하기
  /// [groupId] 그룹 ID
  Future<String> createInvitationUrl(int groupId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/invitations/$groupId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return data['invitationUrl'];
    } else {
      throw Exception(
        '초대 URL 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 초대 링크 유효성 확인
  /// [token] 초대 토큰
  Future<Map<String, dynamic>> checkInvitationStatus(String token) async {
    final authToken = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(authToken)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/join-request/$token');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        '초대 링크 확인에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 그룹 가입 신청하기
  /// [token] 초대 토큰
  Future<void> joinGroupRequest(String token) async {
    final authToken = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(authToken)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/join-request/$token');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        '그룹 가입 신청에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 가입 요청 승인/거절하기
  /// [groupId] 그룹 ID
  /// [token] 초대 토큰
  /// [accept] 수락 여부
  /// [applicantId] 가입 신청자 ID
  /// [adminComment] 관리자 코멘트
  Future<void> approveOrRejectInvitation({
    required int groupId,
    required String token,
    required bool accept,
    required int applicantId,
    String? adminComment,
  }) async {
    final authToken = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(authToken)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl$apiPrefix/$groupId/invitations/response/$token?accept=$accept&applicantId=$applicantId',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'adminComment': adminComment ?? ''}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        '가입 요청 처리에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 그룹 정보 수정하기
  /// [groupId] 그룹 ID
  /// [name] 수정할 그룹 이름
  /// [description] 수정할 그룹 설명
  /// [isPublic] 수정할 공개 여부
  Future<Group> updateGroup({
    required int groupId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/$groupId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'isPublic': isPublic,
      }),
    );

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        '그룹 수정에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 내 그룹 목록 조회하기
  Future<List<Group>> getMyGroups() async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/my-groups');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception(
        '내 그룹 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 그룹 상세 정보 및 그룹원 조회하기
  /// [groupId] 그룹 ID
  Future<GroupDetail> getGroupDetails(int groupId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/group-detail/$groupId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return GroupDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        '그룹 상세 정보 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// 그룹 가입 요청 목록 조회하기
  /// [groupId] 그룹 ID
  Future<List<GroupJoinRequest>> getJoinRequestList(int groupId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/join-requests-list/$groupId');
    debugPrint('가입 요청 목록 API 호출: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        debugPrint('응답 데이터: $responseBody');

        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((json) => GroupJoinRequest.fromJson(json)).toList();
      } else {
        throw Exception(
          '가입 요청 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('가입 요청 API 호출 오류: $e');
      rethrow;
    }
  }

  /// 그룹 삭제하기
  /// [groupId] 그룹 ID
  Future<void> deleteGroup(int groupId) async {
    final token = await _getAuthToken();

    // 토큰 유효성 검사
    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    debugPrint('그룹 삭제 API 호출: groupId=$groupId');
    final url = Uri.parse('$baseUrl$apiPrefix/$groupId');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('그룹 삭제 API 응답: ${response.statusCode}, 본문: ${response.body}');

      // 응답 코드 범위를 넓혀서 성공 조건 완화
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          '그룹 삭제에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('그룹 삭제 API 예외 발생: $e');
      rethrow;
    }
  }
}
