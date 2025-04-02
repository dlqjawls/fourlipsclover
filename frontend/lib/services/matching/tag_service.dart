import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../models/matching/matching_tag_model.dart';

class TagService {
   String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) {
      throw Exception('API_BASE_URL이 .env 파일에 정의되지 않았습니다.');
    }
    return url;
  }
  Future<List<Tag>> getTags() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tag'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      debugPrint('Tag API Status Code: ${response.statusCode}'); // 디버깅용

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);
        debugPrint('Tag API Response: $jsonData'); // 디버깅용
        return jsonData.map((json) => Tag.fromJson(json)).toList();
      } 
      throw Exception('태그 로드에 실패했습니다. 상태 코드: ${response.statusCode}');
    } catch (e) {
      debugPrint('Tag API Error: $e'); // 디버깅용
      throw Exception('태그 로드 중 오류가 발생했습니다: $e');
    }
  }
}