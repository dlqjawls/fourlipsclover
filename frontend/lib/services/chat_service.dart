import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/plan/plan_list_model.dart';
import 'package:frontend/models/plan/plan_schedule_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatService {
  final String baseUrl = ApiConfig.baseUrl;
  // 디버그 모드 설정 (개발 환경에서만 true로 설정)
  final bool _isDebugMode = true;

  // 채팅방 ID와 매칭 ID의 매핑을 저장하는 정적 맵
  static final Map<int, int> _chatRoomToMatchIdMap = {};

  final _secureStorage = const FlutterSecureStorage();

  // 매핑 저장 메서드
  static void saveChatRoomMatchIdMapping(int chatRoomId, int matchId) {
    _chatRoomToMatchIdMap[chatRoomId] = matchId;
    debugPrint('💾 매핑 저장: 채팅방 ID $chatRoomId -> 매칭 ID $matchId');
  }

  // 매핑 조회 메서드
  static int? getMatchIdForChatRoom(int chatRoomId) {
    final matchId = _chatRoomToMatchIdMap[chatRoomId];
    debugPrint('🔍 매핑 조회: 채팅방 ID $chatRoomId -> 매칭 ID ${matchId ?? "없음"}');
    return matchId;
  }

  // 요청 로깅 함수
  void _logRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic body,
  ) {
    if (!_isDebugMode) return;

    debugPrint('🌐 API 요청: $method $url');
    if (headers != null) {
      debugPrint('📋 헤더: ${headers.toString()}');
    }
    if (body != null) {
      debugPrint('📦 요청 본문: $body');
    }
  }

  // 응답 로깅 함수
  void _logResponse(http.Response response, String endpoint) {
    if (!_isDebugMode) return;

    final statusEmoji =
        response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '❌';

    debugPrint('$statusEmoji API 응답: [${response.statusCode}] $endpoint');

    // 응답 본문이 너무 길면 일부만 출력
    try {
      final responseBody = utf8.decode(response.bodyBytes);
      final truncatedBody =
          responseBody.length > 500
              ? '${responseBody.substring(0, 500)}... (${responseBody.length - 500}자 더 있음)'
              : responseBody;

      debugPrint('📄 응답 본문: $truncatedBody');

      // JSON 응답 분석 시도
      try {
        final decodedJson = jsonDecode(responseBody);
        if (decodedJson is Map && decodedJson.containsKey('error')) {
          debugPrint('🔴 에러 메시지: ${decodedJson['error']}');
        }
      } catch (e) {
        debugPrint('❗ JSON 파싱 실패: $e');
      }
    } catch (e) {
      debugPrint('❗ 응답 본문 디코딩 실패: $e');
    }
  }

  // 인증 토큰 가져오기
  Future<String?> _getAuthToken() async {
    final token = await _secureStorage.read(key: 'jwt_token');

    // 디버깅을 위해 토큰 존재 여부 출력
    debugPrint('토큰 존재 여부: ${token != null}');
    if (token == null) {
      debugPrint('경고: JWT 토큰이 SecureStorage에 저장되어 있지 않습니다.');
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

  // 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/chat/rooms';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('GET', url, headers, null);

      final response = await http.get(Uri.parse(url), headers: headers);

      _logResponse(response, 'getChatRooms');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final chatRooms = data.map((json) => ChatRoom.fromJson(json)).toList();

        // 채팅방 ID와 매칭 ID 매핑 정보 저장
        for (final room in chatRooms) {
          saveChatRoomMatchIdMapping(room.chatRoomId, room.matchId);
        }

        return chatRooms;
      } else {
        throw Exception('채팅방 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('채팅방 목록 조회 중 오류 발생: $e');
      throw Exception('채팅방 목록 조회 중 오류 발생: $e');
    }
  }

  // 특정 채팅방 조회
  Future<ChatRoomDetail> getChatRoom(
    int chatRoomId,
    int offset,
    int limit,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url =
          '$baseUrl/api/chat/room/$chatRoomId?offset=$offset&limit=$limit';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('GET', url, headers, null);

      final response = await http.get(Uri.parse(url), headers: headers);

      _logResponse(response, 'getChatRoom/$chatRoomId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return ChatRoomDetail.fromJson(data);
      } else {
        throw Exception('채팅방 정보를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('채팅방 조회 중 오류 발생: $e');
      throw Exception('채팅방 조회 중 오류 발생: $e');
    }
  }

  // 메시지 전송
  Future<ChatMessage> sendMessage(
    int chatRoomId,
    int senderId,
    String messageContent,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/chat/send/$chatRoomId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'type': 'TEXT',
        'senderId': senderId,
        'messageContent': messageContent,
      });

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response, 'sendMessage/$chatRoomId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return ChatMessage.fromJson(data);
      } else {
        throw Exception('메시지 전송에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('메시지 전송 중 오류 발생: $e');
      throw Exception('메시지 전송 중 오류 발생: $e');
    }
  }

  // 새 메시지 가져오기 (Long Polling)
  Future<List<ChatMessage>> getNewMessages(
    int chatRoomId,
    DateTime after,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final formattedDate = after.toIso8601String();
      final url = '$baseUrl/api/chat/$chatRoomId/messages?after=$formattedDate';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 롱폴링은 너무 자주 로깅하면 로그가 과도하게 많이 쌓이므로 간소화
      if (_isDebugMode) {
        debugPrint('📨 새 메시지 확인: $url');
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      // 새 메시지가 있는 경우에만 로깅
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.isNotEmpty && _isDebugMode) {
          debugPrint('📬 새 메시지 ${data.length}개 수신: $chatRoomId');
        }
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        if (_isDebugMode) {
          debugPrint('❌ 새 메시지 확인 실패: [${response.statusCode}] $chatRoomId');
        }
        throw Exception('새 메시지를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('새 메시지 조회 중 오류 발생: $e');
      throw Exception('새 메시지 조회 중 오류 발생: $e');
    }
  }

  // 채팅방에 멤버 초대
  Future<void> inviteMembers(int chatRoomId, List<int> memberIds) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      // chatRoomId는 실제 API에서는 matchId로 사용됨
      final url = '$baseUrl/api/chat/invite/$chatRoomId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({'memberIds': memberIds});

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response, 'inviteMembers/$chatRoomId');

      if (response.statusCode != 200) {
        throw Exception('멤버 초대에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('멤버 초대 중 오류 발생: $e');
      throw Exception('멤버 초대 중 오류 발생: $e');
    }
  }

  // 이미지 메시지 전송
  Future<ChatMessage> sendImageMessage(
    int chatRoomId,
    String messageContent,
    List<File> imageFiles,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/chat/send/$chatRoomId/images';

      debugPrint('🌄 이미지 메시지 전송: $url');
      debugPrint('📷 이미지 개수: ${imageFiles.length}개');

      // multipart/form-data 요청 생성
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // 헤더 설정
      request.headers['Authorization'] = 'Bearer $token';

      // 메시지 내용 추가
      request.fields['messageContent'] = messageContent;

      // 이미지 파일들 추가
      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', imageFile.path),
        );
      }

      // 요청 전송
      debugPrint('📤 이미지 업로드 시작...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response, 'sendImageMessage/$chatRoomId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return ChatMessage.fromJson(data);
      } else {
        throw Exception('이미지 메시지 전송에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('이미지 메시지 전송 중 오류 발생: $e');
      throw Exception('이미지 메시지 전송 중 오류 발생: $e');
    }
  }

  // 채팅방 나가기
  Future<void> leaveChatRoom(int chatRoomId) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/chat/$chatRoomId/leave';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('DELETE', url, headers, null);

      final response = await http.delete(Uri.parse(url), headers: headers);

      _logResponse(response, 'leaveChatRoom/$chatRoomId');

      if (response.statusCode != 200) {
        throw Exception('채팅방 나가기에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('채팅방 나가기 중 오류 발생: $e');
      throw Exception('채팅방 나가기 중 오류 발생: $e');
    }
  }

  // 그룹에 소속된 plan 목록 조회
  Future<List<PlanList>> getGroupPlans(int groupId) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/group/$groupId/plan';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('GET', url, headers, null);

      final response = await http.get(Uri.parse(url), headers: headers);

      _logResponse(response, 'getGroupPlans/$groupId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => PlanList.fromJson(json)).toList();
      } else {
        throw Exception('그룹의 계획 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('그룹 계획 목록 조회 중 오류 발생: $e');
      throw Exception('그룹 계획 목록 조회 중 오류 발생: $e');
    }
  }

  // 그룹의 모든 인원을 조회하고 plan 및 채팅방 소속 여부를 표시
  Future<List<Map<String, dynamic>>> getAvailableMembers(
    int groupId,
    int planId, {
    int? chatRoomId,
  }) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      // 1. 그룹의 모든 멤버 조회
      final groupUrl = '$baseUrl/api/group/group-detail/$groupId';
      final planUrl = '$baseUrl/api/group/$groupId/plan/$planId';

      // 채팅방 참여자 조회 URL (chatRoomId가 제공된 경우)
      String? chatRoomUrl;
      if (chatRoomId != null) {
        chatRoomUrl = '$baseUrl/api/chat/room/$chatRoomId?offset=0&limit=1';
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      };

      _logRequest('GET', groupUrl, headers, null);
      _logRequest('GET', planUrl, headers, null);
      if (chatRoomUrl != null) {
        _logRequest('GET', chatRoomUrl, headers, null);
      }

      // API 요청들
      final groupResponse = await http.get(
        Uri.parse(groupUrl),
        headers: headers,
      );
      final planResponse = await http.get(Uri.parse(planUrl), headers: headers);

      // 채팅방 정보 조회 (선택적)
      http.Response? chatRoomResponse;
      if (chatRoomUrl != null) {
        chatRoomResponse = await http.get(
          Uri.parse(chatRoomUrl),
          headers: headers,
        );
      }

      _logResponse(groupResponse, 'getGroupDetail/$groupId');
      _logResponse(planResponse, 'getPlanDetail/$groupId/$planId');
      if (chatRoomResponse != null) {
        _logResponse(chatRoomResponse, 'getChatRoom/$chatRoomId');
      }

      // 응답 처리
      if (groupResponse.statusCode != 200) {
        throw Exception('그룹 정보를 불러오는데 실패했습니다: ${groupResponse.statusCode}');
      }

      if (planResponse.statusCode != 200) {
        throw Exception('플랜 정보를 불러오는데 실패했습니다: ${planResponse.statusCode}');
      }

      // 그룹 및 플랜 데이터 파싱
      final groupData = jsonDecode(utf8.decode(groupResponse.bodyBytes));
      final planData = jsonDecode(utf8.decode(planResponse.bodyBytes));

      // 채팅방 멤버 ID 집합 (chatRoomId가 제공된 경우)
      Set<int> chatMemberIds = {};
      if (chatRoomResponse != null && chatRoomResponse.statusCode == 200) {
        final chatRoomData = jsonDecode(
          utf8.decode(chatRoomResponse.bodyBytes),
        );
        final List<dynamic> chatMembers = chatRoomData['members'] ?? [];
        chatMemberIds =
            chatMembers.map<int>((member) => member['memberId'] as int).toSet();
        debugPrint('👥 채팅방 참여자 수: ${chatMemberIds.length}명');
      }

      // 그룹 멤버 목록
      final List<dynamic> groupMembers = groupData['members'] ?? [];

      // 플랜 멤버 목록
      final List<dynamic> planMembers = planData['members'] ?? [];

      // 플랜 멤버 ID 목록 생성 (빠른 조회를 위해)
      final Set<int> planMemberIds =
          planMembers.map<int>((member) => member['memberId'] as int).toSet();

      // 그룹 멤버 목록에 isInPlan 및 isInChat 속성 추가
      final result =
          groupMembers.map<Map<String, dynamic>>((member) {
            final memberId = member['memberId'] as int;
            final isInPlan = planMemberIds.contains(memberId);
            final isInChat = chatMemberIds.contains(memberId);

            return {
              ...Map<String, dynamic>.from(member as Map),
              'isInPlan': isInPlan,
              'isInChat': isInChat,
            };
          }).toList();

      return result;
    } catch (e) {
      debugPrint('그룹/플랜/채팅방 멤버 목록 조회 중 오류 발생: $e');
      throw Exception('그룹/플랜/채팅방 멤버 목록 조회 중 오류 발생: $e');
    }
  }

  // 채팅방 내에서 현지인이 기획서 작성
  Future<Map<String, dynamic>> createGuideProposal(
    Map<String, dynamic> proposalData,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/match/guide/proposal';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode(proposalData);

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response, 'createGuideProposal');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return data;
      } else {
        throw Exception('기획서 작성에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('기획서 작성 중 오류 발생: $e');
      throw Exception('기획서 작성 중 오류 발생: $e');
    }
  }

  // planSchedule 생성
  Future<PlanSchedule> createPlanSchedule(
    int groupId,
    int planId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/group/$groupId/plan/$planId/schedule/create';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode(scheduleData);

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response, 'createPlanSchedule/$groupId/$planId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return PlanSchedule.fromJson(data);
      } else {
        throw Exception('일정 생성에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('일정 생성 중 오류 발생: $e');
      throw Exception('일정 생성 중 오류 발생: $e');
    }
  }

  // planSchedule 목록 조회 (롱풀링 적용)
  Future<List<PlanSchedule>> getPlanSchedules(int groupId, int planId) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url = '$baseUrl/api/group/$groupId/plan/$planId/schedule';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 롱폴링은 로그 축소
      if (_isDebugMode) {
        debugPrint('📅 일정 목록 조회: $url');
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (_isDebugMode) {
          debugPrint('📅 일정 ${data.length}개 로드됨');
        }
        return data.map((json) => PlanSchedule.fromJson(json)).toList();
      } else {
        if (_isDebugMode) {
          debugPrint('❌ 일정 목록 조회 실패: [${response.statusCode}]');
        }
        throw Exception('일정 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('일정 목록 조회 중 오류 발생: $e');
      throw Exception('일정 목록 조회 중 오류 발생: $e');
    }
  }

  // planSchedule 상세 조회
  Future<PlanSchedule> getPlanScheduleDetail(
    int groupId,
    int planId,
    int scheduleId,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url =
          '$baseUrl/api/group/$groupId/plan/$planId/schedule/$scheduleId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('GET', url, headers, null);

      final response = await http.get(Uri.parse(url), headers: headers);

      _logResponse(
        response,
        'getPlanScheduleDetail/$groupId/$planId/$scheduleId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return PlanSchedule.fromJson(data);
      } else {
        throw Exception('일정 상세 정보를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('일정 상세 조회 중 오류 발생: $e');
      throw Exception('일정 상세 조회 중 오류 발생: $e');
    }
  }

  // planSchedule 수정 (방문 날짜 혹은 시간)
  Future<PlanSchedule> updatePlanSchedule(
    int groupId,
    int planId,
    int scheduleId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url =
          '$baseUrl/api/group/$groupId/plan/$planId/schedule/update/$scheduleId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode(updateData);

      _logRequest('PUT', url, headers, body);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response, 'updatePlanSchedule/$groupId/$planId/$scheduleId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return PlanSchedule.fromJson(data);
      } else {
        throw Exception('일정 수정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('일정 수정 중 오류 발생: $e');
      throw Exception('일정 수정 중 오류 발생: $e');
    }
  }

  // planSchedule 삭제
  Future<void> deletePlanSchedule(
    int groupId,
    int planId,
    int scheduleId,
  ) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final url =
          '$baseUrl/api/group/$groupId/plan/$planId/schedule/delete/$scheduleId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      _logRequest('DELETE', url, headers, null);

      final response = await http.delete(Uri.parse(url), headers: headers);

      _logResponse(response, 'deletePlanSchedule/$groupId/$planId/$scheduleId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('일정 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('일정 삭제 중 오류 발생: $e');
      throw Exception('일정 삭제 중 오류 발생: $e');
    }
  }
}
