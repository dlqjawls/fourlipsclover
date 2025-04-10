import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/matching/matching_region.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/config/api_config.dart';
class RegionService {
  final String baseUrl = ApiConfig.baseUrl;
  Future<List<Region>> getRegions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/match/region-list'),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);
        debugPrint('Region API Response: $jsonData'); // 디버깅용
        return jsonData.map((json) => Region.fromJson(json)).toList();
      }
      throw Exception('지역 목록을 불러오는데 실패했습니다');
    } catch (e) {
      debugPrint('Region API Error: $e'); // 디버깅용
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }
}
