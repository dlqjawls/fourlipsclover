import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/models/local_certification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalCertificationService {
  final baseUrl = dotenv.env['API_BASE_URL'];

  Future<LocalCertification> createLocalCertification({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 토큰 가져오기
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');

      debugPrint('저장된 토큰: $token');

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // JWT 토큰 디코딩
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      debugPrint('디코딩된 토큰: $decodedToken');

      final int memberId = int.parse(decodedToken['sub']);
      debugPrint('추출된 memberId: $memberId');

      final url = '$baseUrl/api/local-certification/$memberId';
      debugPrint('요청 URL: $url');

      // API 요청
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // UTF-8 인코딩 명시
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      debugPrint('응답 상태 코드: ${response.statusCode}');
      debugPrint('응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedBody);

        debugPrint('디코딩된 응답: $data');
        return LocalCertification.fromJson(data);
      } else {
        throw Exception(
          '현지인 인증 생성 실패\n'
          '상태 코드: ${response.statusCode}\n'
          '응답: ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('에러 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
      throw Exception('현지인 인증 처리 중 오류 발생: $e');
    }
  }
}
