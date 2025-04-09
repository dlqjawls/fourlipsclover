// lib/services/api/tag_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/tag_model.dart';

class TagApi {
  // 베이스 URL을 .env 파일에서 가져오거나 기본값 설정
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }
  static const String apiPrefix = '/api/tag';

  /// 태그 전체 목록 조회 (현재 사용 가능한 유일한 API)
  static Future<List<TagModel>> getTagList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => TagModel.fromJson(item)).toList();
      } else {
        throw Exception('태그 목록 조회 중 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('태그 목록 조회 중 오류가 발생했습니다: $e');
    }
  }
}