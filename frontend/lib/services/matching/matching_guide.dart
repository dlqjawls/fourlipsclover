import 'package:dio/dio.dart';
import 'package:frontend/models/matching/matching_guide_model.dart';
import 'package:frontend/config/api_config.dart';

class LocalGuideService {
  final Dio _dio;

  LocalGuideService() : _dio = Dio() {
    final String url = ApiConfig.baseUrl;

    _dio.options.baseUrl = url;
  }

  Future<List<LocalGuide>> getLocalGuides(int memberId, int regionId) async {
    try {
      final response = await _dio.get(
        '/api/locals/$memberId/find-locals/$regionId',
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((guide) => LocalGuide.fromJson(guide))
            .toList();
      } else {
        throw Exception('가이드 정보를 불러오는데 실패했습니다');
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('해당 지역의 가이드를 찾을 수 없습니다');
      }
      throw Exception('서버 연결 오류: ${e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }
}
