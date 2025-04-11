import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) throw Exception('API_BASE_URL이 .env 파일에 정의되지 않았습니다.');
    return url;
  }
}
