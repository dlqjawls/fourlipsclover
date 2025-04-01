import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/matching/matching_tag_model.dart';

class TagService {
  final String baseUrl = 'https://fourlipsclover.duckdns.org/api';

  Future<List<Tag>> getTags() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tag'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // UTF-8로 디코딩
      final String decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonData = json.decode(decodedBody);
      return jsonData.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('태그 로드에 실패했습니다');
    }
  }
}
