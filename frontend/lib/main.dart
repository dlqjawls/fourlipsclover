import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY'); // 여기에 네이티브 앱 키 입력
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> loginWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      var user = await UserApi.instance.me();
      print('로그인 성공! 사용자 정보: ${user.kakaoAccount?.profile?.nickname}');
    } catch (e) {
      print('로그인 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("카카오 로그인")),
      body: Center(
        child: ElevatedButton(
          onPressed: loginWithKakao,
          child: Text("카카오 로그인"),
        ),
      ),
    );
  }
}
