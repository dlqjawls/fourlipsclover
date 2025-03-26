// lib/services/kakao_route_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/route_model.dart';

class KakaoRouteService {
  static const String baseUrl = 'https://apis-navi.kakaomobility.com/v1/directions';
  
  // 환경 변수에서 API 키 가져오기
  static String get apiKey => dotenv.env['KAKAO_MOBILITY_APP_KEY'] ?? '';
  
  // 자동차 길찾기 API 호출
  static Future<KakaoRouteResponse> getCarRoute({
    required double originLng,
    required double originLat,
    required double destinationLng,
    required double destinationLat,
    List<Map<String, double>>? waypoints,
    String priority = 'RECOMMEND',
    bool alternatives = false,
    bool roadDetails = true,
    String carFuel = 'GASOLINE',
    bool carHipass = false,
  }) async {
    try {
      // 출발지와 목적지 좌표 포맷팅
      String origin = '$originLng,$originLat';
      String destination = '$destinationLng,$destinationLat';
      
      // 경유지 포맷팅 (있는 경우)
      String waypointsParam = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        waypointsParam = waypoints
            .map((wp) => '${wp['longitude']},${wp['latitude']}')
            .join('|');
      }
      
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {
        'origin': origin,
        'destination': destination,
        'priority': priority,
        'car_fuel': carFuel,
        'car_hipass': carHipass.toString(),
        'alternatives': alternatives.toString(),
        'road_details': roadDetails.toString(),
      };
      
      // 경유지 추가 (있는 경우)
      if (waypointsParam.isNotEmpty) {
        queryParams['waypoints'] = waypointsParam;
      }
      
      // URI 구성
      Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      // HTTP 요청 헤더
      Map<String, String> headers = {
        'Authorization': 'KakaoAK $apiKey',
        'Content-Type': 'application/json',
      };
      
      // GET 요청 보내기
      final response = await http.get(uri, headers: headers);
      
      // 응답 상태 코드 확인
      if (response.statusCode == 200) {
        // JSON 응답을 Dart 객체로 변환
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return KakaoRouteResponse.fromJson(jsonResponse);
      } else {
        throw Exception('길찾기 API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('길찾기 API 오류: $e');
      rethrow;
    }
  }
}