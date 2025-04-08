import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final String baseUrl = ApiConfig.baseUrl;

  // 인증 토큰 가져오기
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

  // 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ChatRoom.fromJson(json)).toList();
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

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/chat/room/$chatRoomId?offset=$offset&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/send/$chatRoomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': 'TEXT',
          'senderId': senderId,
          'messageContent': messageContent,
        }),
      );

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
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/chat/$chatRoomId/messages?after=$formattedDate',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('새 메시지를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('새 메시지 조회 중 오류 발생: $e');
      throw Exception('새 메시지 조회 중 오류 발생: $e');
    }
  }

  // 채팅방에 멤버 초대
  Future<void> inviteMembers(int matchId, List<int> memberIds) async {
    try {
      final token = await _getAuthToken();

      if (!_validateToken(token)) {
        throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/invite/$matchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'memberIds': memberIds}),
      );

      if (response.statusCode != 200) {
        throw Exception('멤버 초대에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('멤버 초대 중 오류 발생: $e');
      throw Exception('멤버 초대 중 오류 발생: $e');
    }
  }
}
