// lib/services/api/notice_api.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notice/notice_model.dart';
import 'api_util.dart';

class NoticeApi {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String apiPrefix = '/api/plan-notice';

  // 인증 토큰 가져오기 (ApiUtil 사용)
  Future<String?> _getAuthToken() async {
    return await ApiUtil.getJwtToken();
  }

  // 토큰 유효성 검사 (ApiUtil 사용)
  bool _validateToken(String? token) {
    return ApiUtil.validateToken(token);
  }

  /// 공지사항 생성하기
  /// [planId] 계획 ID
  /// [notice] 공지사항 모델
  Future<NoticeModel> createNotice(int planId, NoticeModel notice) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/create/$planId');

    debugPrint('공지사항 생성 API 호출: $url');
    debugPrint('요청 본문: ${jsonEncode(notice.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(notice.toJson()),
      );

      debugPrint('응답 코드: ${response.statusCode}');
      debugPrint('응답 본문: ${response.body}');

      if (response.statusCode == 201) {
        return NoticeModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '공지사항 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 계획의 모든 공지사항 조회하기
  /// [planId] 계획 ID
  Future<List<NoticeModel>> getNotices(int planId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/list/$planId');

    debugPrint('공지사항 조회 API 호출: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => NoticeModel.fromJson(json)).toList();
      } else {
        throw Exception(
          '공지사항 목록 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 공지사항 수정하기
  /// [planNoticeId] 공지사항 ID
  /// [notice] 수정할 공지사항 모델
  Future<NoticeModel> updateNotice(int planNoticeId, NoticeModel notice) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/update/$planNoticeId');

    debugPrint('공지사항 수정 API 호출: $url');
    debugPrint('요청 본문: ${jsonEncode(notice.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(notice.toJson()),
      );

      debugPrint('응답 코드: ${response.statusCode}');
      debugPrint('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return NoticeModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '공지사항 수정에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 공지사항 삭제하기
  /// [planNoticeId] 공지사항 ID
  Future<void> deleteNotice(int planNoticeId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$apiPrefix/delete/$planNoticeId');

    debugPrint('공지사항 삭제 API 호출: $url');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode != 204) {
        throw Exception(
          '공지사항 삭제에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
}
