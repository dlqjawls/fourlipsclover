// lib/services/api/group_analysis_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/analysis/group_analysis_model.dart';
import 'package:frontend/models/analysis/category_analysis_model.dart';

class GroupAnalysisApi {
  // 베이스 URL을 .env 파일에서 가져오거나 기본값 설정
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  static const String apiAnalysisPrefix = '/api/analysis';
  static const String apiSpendingAnalysisPrefix = '/api/spending-analysis';

  // 그룹 분석 결과 조회
  static Future<GroupAnalysisResult?> getGroupAnalysis(int groupId) async {
    try {
      print('그룹 분석 API 요청: $baseUrl$apiAnalysisPrefix/group/$groupId');
      
      final response = await http.get(
        Uri.parse('$baseUrl$apiAnalysisPrefix/group/$groupId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // 응답 바디 로깅 (디버깅용)
        print('API 응답 데이터: ${response.body.length > 1000 ? '${response.body.substring(0, 1000)}...' : response.body}');
        
        try {
          // 분석 결과가 있는 경우
          final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          return GroupAnalysisResult.fromJson(data);
        } catch (parseError) {
          print('응답 파싱 오류: $parseError');
          print('응답 바디 일부: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
          throw Exception('응답 파싱 중 오류 발생: $parseError');
        }
      } else if (response.statusCode == 202) {
        // 분석이 진행 중인 경우
        print('그룹 $groupId 분석 진행 중');
        return null;
      } else {
        print('실패 응답: ${response.statusCode}, 응답 본문: ${response.body}');
        throw Exception('그룹 분석 결과 조회 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('그룹 분석 결과 조회 예외 발생: $e');
      throw Exception('그룹 분석 결과 조회 중 오류 발생: $e');
    }
  }

  // 그룹의 특정 분석 유형 결과 조회
  static Future<Map<String, dynamic>?> getGroupAnalysisByType(
      int groupId, String analysisType) async {
    try {
      print('특정 분석 유형 API 요청: $baseUrl$apiAnalysisPrefix/group/$groupId/$analysisType');
      
      final response = await http.get(
        Uri.parse('$baseUrl$apiAnalysisPrefix/group/$groupId/$analysisType'),
        headers: {'Content-Type': 'application/json'},
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          return data;
        } catch (parseError) {
          print('응답 파싱 오류: $parseError');
          print('응답 바디 일부: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
          throw Exception('응답 파싱 중 오류 발생: $parseError');
        }
      } else if (response.statusCode == 404) {
        // 분석 결과가 없는 경우
        print('그룹 $groupId의 $analysisType 분석 결과 없음');
        return null;
      } else {
        print('실패 응답: ${response.statusCode}, 응답 본문: ${response.body}');
        throw Exception('특정 분석 유형 결과 조회 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('특정 분석 유형 결과 조회 예외 발생: $e');
      throw Exception('특정 분석 유형 결과 조회 중 오류 발생: $e');
    }
  }

  // 그룹의 카테고리별 지출 분석
  static Future<CategoryAnalysisResult?> getGroupCategoryAnalysis(
      int groupId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {};
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      // URL 생성
      Uri uri = Uri.parse('$baseUrl$apiSpendingAnalysisPrefix/group/category/$groupId')
          .replace(queryParameters: queryParams);

      print('카테고리 분석 API 요청 URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          return CategoryAnalysisResult.fromJson(data);
        } catch (parseError) {
          print('응답 파싱 오류: $parseError');
          print('응답 바디 일부: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
          throw Exception('응답 파싱 중 오류 발생: $parseError');
        }
      } else if (response.statusCode == 404) {
        // 분석 결과가 없는 경우
        print('그룹 $groupId의 카테고리 분석 결과 없음');
        return null;
      } else {
        print('실패 응답: ${response.statusCode}, 응답 본문: ${response.body}');
        throw Exception('카테고리 분석 결과 조회 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('카테고리 분석 결과 조회 예외 발생: $e');
      throw Exception('카테고리 분석 결과 조회 중 오류 발생: $e');
    }
  }
}