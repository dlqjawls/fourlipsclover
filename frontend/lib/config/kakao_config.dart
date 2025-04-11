import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoConfig {
  static String get nativeAppKey => dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }
}