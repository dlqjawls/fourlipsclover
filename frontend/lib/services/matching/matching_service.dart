import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/matching/matching_main_model.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  
  factory MatchingService() {
    return _instance;
  }

  MatchingService._internal();
  
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<void> initializeMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole');
      final service = MatchingService();
      
      debugPrint('=== 매칭 목록 초기화 시작 ===');
      debugPrint('사용자 역할: $userRole');
      
      if (userRole == 'GUIDE') {
        await service.getGuideMatchRequests();
      } else {
        await service.getApplicantMatches();
      }
      debugPrint('=== 매칭 목록 초기화 완료 ===');
    } catch (e) {
      debugPrint('=== 매칭 목록 초기화 실패 ===');
      debugPrint('초기화 중 오류 발생: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<MatchRequest>> getGuideMatchRequests() async {
    try {
      final token = await _getToken();
      debugPrint('=== 가이드 매칭 요청 시작 ===');
      debugPrint('인증 토큰: $token');
      debugPrint('요청 URL: $baseUrl/api/match/guide');

      final response = await http.get(
        Uri.parse('$baseUrl/api/match/guide'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      debugPrint('응답 헤더: ${response.headers}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        debugPrint('원본 응답 데이터: $decodedBody');
        
        final List<dynamic> data = json.decode(decodedBody);
        debugPrint('JSON 파싱 결과: $data');
        final List<MatchRequest> matches = [];
        
        for (var item in data) {
          try {
            final match = MatchRequest.fromJson(item);
            matches.add(match);
            debugPrint('매칭 데이터 변환 성공: ${match.matchId}');
          } catch (e) {
            debugPrint('데이터 변환 실패: $e');
            debugPrint('실패한 데이터: $item');
            rethrow;
          }
        }

        debugPrint('성공적으로 변환된 매칭 수: ${matches.length}');
        debugPrint('=== 가이드 매칭 요청 완료 ===');
        return matches;
      } else {
        final String errorMessage = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> errorJson = json.decode(errorMessage);
        debugPrint('응답 오류 내용: ${errorJson['error'] ?? errorMessage}');
        debugPrint('=== 가이드 매칭 요청 실패 ===');
        
        if (response.statusCode == 404) {
          throw Exception('매칭 신청 내역이 없습니다.');
        } else {
          throw Exception('매칭 신청 목록 조회 실패 (${response.statusCode})');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== 가이드 매칭 요청 중 예외 발생 ===');
      debugPrint('예외 내용: $e');
      debugPrint('스택 트레이스: $stackTrace');
      throw Exception('매칭 신청 목록 조회 중 오류 발생: $e');
    }
  }

  Future<List<MatchApplication>> getApplicantMatches() async {
    try {
      final token = await _getToken();
      debugPrint('=== 신청자 매칭 요청 시작 ===');
      debugPrint('인증 토큰: $token');
      debugPrint('요청 URL: $baseUrl/api/match');

      final response = await http.get(
        Uri.parse('$baseUrl/api/match'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      debugPrint('응답 헤더: ${response.headers}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        debugPrint('원본 응답 데이터: $decodedBody');
        
        final List<dynamic> data = json.decode(decodedBody);
        debugPrint('JSON 파싱 결과: $data');
        final List<MatchApplication> matches = [];
        
        for (var item in data) {
          try {
            final match = MatchApplication.fromJson(item);
            matches.add(match);
            debugPrint('매칭 데이터 변환 성공: ${match.guideNickname}');
          } catch (e) {
            debugPrint('데이터 변환 실패: $e');
            debugPrint('실패한 데이터: $item');
            rethrow;
          }
        }

        debugPrint('성공적으로 변환된 매칭 수: ${matches.length}');
        debugPrint('=== 신청자 매칭 요청 완료 ===');
        return matches;
      } else {
        final String errorMessage = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> errorJson = json.decode(errorMessage);
        debugPrint('응답 오류 내용: ${errorJson['error']}');
        debugPrint('=== 신청자 매칭 요청 실패 ===');
        
        if (response.statusCode == 404) {
          throw Exception('매칭 신청 내역이 없습니다.');
        } else {
          throw Exception('매칭 신청 목록 조회 실패 (${response.statusCode})');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== 신청자 매칭 요청 중 예외 발생 ===');
      debugPrint('예외 내용: $e');
      debugPrint('스택 트레이스: $stackTrace');
      throw Exception('매칭 신청 목록 조회 중 오류 발생: $e');
    }
  }

  Future<void> respondToMatch({
    required int matchId,
    required int localId,
    required String action,
    required String message,
  }) async {
    try {
      final token = await _getToken();
      debugPrint('=== 매칭 응답 요청 시작 ===');
      debugPrint('매칭 ID: $matchId, 액션: $action');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/match/$matchId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'match_id': matchId,
          'local_id': localId,
          'action': action,
          'message': message,
        }),
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      debugPrint('응답 헤더: ${response.headers}');

      if (response.statusCode != 200) {
        final String errorMessage = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> errorJson = json.decode(errorMessage);
        debugPrint('응답 오류 내용: ${errorJson['error'] ?? errorMessage}');
        debugPrint('=== 매칭 응답 요청 실패 ===');
        throw Exception('매칭 응답 처리 실패: ${errorJson['error'] ?? "알 수 없는 오류"}');
      }

      debugPrint('=== 매칭 응답 요청 완료 ===');
    } catch (e, stackTrace) {
      debugPrint('=== 매칭 응답 요청 중 예외 발생 ===');
      debugPrint('예외 내용: $e');
      debugPrint('스택 트레이스: $stackTrace');
      throw Exception('매칭 응답 처리 중 오류 발생: $e');
    }
  }
}