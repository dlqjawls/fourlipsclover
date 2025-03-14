import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoConfig {
  static const String nativeAppKey = 'eed918aa9f0ef754a93dec5247e9f38e';

  static Future<void> initialize() async {
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }
}
