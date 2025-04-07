import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/matching/matching_main_model.dart';
import '../../models/matching/matching_detail.dart';
import 'package:frontend/config/api_config.dart';
class MatchingService {
  static final MatchingService _instance = MatchingService._internal();

  factory MatchingService() {
    return _instance;
  }

  MatchingService._internal();

   final String baseUrl = ApiConfig.baseUrl;

  static Future<void> initializeMatches() async {
    try {
      final service = MatchingService();

      debugPrint('=== 매칭 목록 초기화 시작 ===');

      // 두 가지 매칭 리스트 모두 초기화
      await Future.wait([
        service.getGuideMatchRequests().catchError((e) {
          debugPrint('가이드 매칭 초기화 실패: $e');
          return <MatchRequest>[];
        }),
        service.getApplicantMatches().catchError((e) {
          debugPrint('신청자 매칭 초기화 실패: $e');
          return <MatchApplication>[];
        }),
      ]);

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

  Future<Map<String, int>> getMatchingCounts() async {
    int confirmedCount = 0;
    int pendingCount = 0;

    // 확정된 매칭 조회
    final List<MatchRequest> confirmedMatches = await getConfirmedMatches();
    confirmedCount = confirmedMatches.length;
    debugPrint('확정된 매칭: $confirmedCount');

    // 대기중인 매칭 조회
    try {
      final List<MatchRequest> pendingMatches = await getGuideMatchRequests();
      pendingCount = pendingMatches.where((m) => m.status == 'PENDING').length;
    } catch (e) {
      debugPrint('대기중인 매칭 조회 실패: $e');
      // 404는 정상적인 "데이터 없음" 상황이므로 0으로 처리
      pendingCount = 0;
    }

    debugPrint('=== 매칭 카운트 조회 결과 ===');
    debugPrint('확정된 매칭: $confirmedCount');
    debugPrint('대기중인 매칭: $pendingCount');

    // 항상 데이터 반환
    return {'confirmedCount': confirmedCount, 'pendingCount': pendingCount};
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

      final response = await http.get(
        Uri.parse('$baseUrl/api/match'), // URL 수정
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        final List<MatchApplication> matches = [];

        for (var item in data) {
          try {
            matches.add(MatchApplication.fromJson(item));
          } catch (e) {
            debugPrint('데이터 변환 실패: $e');
          }
        }

        debugPrint('조회된 매칭 수: ${matches.length}');
        return matches;
      } else if (response.statusCode == 404) {
        debugPrint('신청한 매칭이 없습니다.');
        return [];
      } else {
        throw Exception('매칭 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('신청자 매칭 조회 중 오류: $e');
      return []; // 오류 발생 시 빈 리스트 반환
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

  Future<List<MatchRequest>> getConfirmedMatches() async {
    try {
      final token = await _getToken();
      debugPrint('=== 확정된 매칭 목록 조회 시작 ===');

      final response = await http.get(
        Uri.parse('$baseUrl/api/match/guide/confirmed'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        debugPrint('응답 데이터: $decodedBody');

        final List<dynamic> data = json.decode(decodedBody);
        final List<MatchRequest> matches = [];

        for (var item in data) {
          matches.add(MatchRequest.fromJson(item));
          debugPrint('매칭 데이터 변환 성공: ${matches.last.matchId}');
        }

        debugPrint('확정된 매칭 수: ${matches.length}');
        return matches;
      } else if (response.statusCode == 404) {
        debugPrint('확정된 매칭이 없습니다.');
        return []; // 빈 리스트 반환
      } else {
        throw Exception('확정된 매칭 목록 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('확정된 매칭 목록 조회 중 오류: $e');
      throw Exception('확정된 매칭 목록 조회 실패: $e');
    }
  }

  Future<void> confirmMatch(int matchId) async {
    try {
      final token = await _getToken();
      debugPrint('=== 매칭 확인 요청 시작 ===');
      debugPrint('매칭 ID: $matchId');

      final response = await http.put(
        Uri.parse('$baseUrl/api/match/guide/confirmed'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('매칭 확인 성공');
      } else {
        throw Exception('매칭 확인 실패 (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('매칭 확인 중 오류: $e');
      throw Exception('매칭 확인 실패: $e');
    }
  }

  Future<MatchingDetail> getMatchDetail(int matchId) async {
    try {
      final token = await _getToken();
      debugPrint('=== 매칭 상세 조회 요청 시작 ===');
      debugPrint('매칭 ID: $matchId');
      debugPrint('요청 URL: $baseUrl/api/match/$matchId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/match/$matchId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      debugPrint('응답 헤더: ${response.headers}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        debugPrint('응답 데이터: $decodedBody');

        final Map<String, dynamic> data = json.decode(decodedBody);
        final detail = MatchingDetail.fromJson(data);

        debugPrint('매칭 상세 정보 변환 성공');
        debugPrint('=== 매칭 상세 조회 완료 ===');
        return detail;
      } else {
        final String errorMessage = utf8.decode(response.bodyBytes);
        debugPrint('오류 응답: $errorMessage');

        if (response.statusCode == 404) {
          throw MatchingDetailException(
            '해당 매칭을 찾을 수 없습니다.',
            response.statusCode,
          );
        } else {
          throw MatchingDetailException('매칭 상세 조회 실패', response.statusCode);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== 매칭 상세 조회 중 예외 발생 ===');
      debugPrint('예외 내용: $e');
      debugPrint('스택 트레이스: $stackTrace');

      if (e is MatchingDetailException) {
        rethrow;
      }
      throw MatchingDetailException('매칭 상세 조회 중 오류가 발생했습니다: $e');
    }
  }
}
