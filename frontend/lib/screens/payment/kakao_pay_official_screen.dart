import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../../services/payment_service.dart';

class KakaoPayOfficialScreen extends StatefulWidget {
  const KakaoPayOfficialScreen({super.key});

  @override
  State<KakaoPayOfficialScreen> createState() => _KakaoPayOfficialScreenState();
}

class _KakaoPayOfficialScreenState extends State<KakaoPayOfficialScreen> {
  /// 새 방식에서는 WebViewController를 먼저 만들고,
  /// WebViewWidget으로 표시합니다.
  late final WebViewController _controller;

  String? paymentUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();


    // if (Platform.isAndroid) {
    //   WebView.platform = AndroidWebView(); // 필요하면 pubspec.yaml에 webview_flutter_android 추가
    // }

    // WebViewController 생성 및 설정
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigation(request);
          },
        ),
      );

    // 결제 준비 요청
    _initPayment();
  }

  // 결제 준비 로직
  Future<void> _initPayment() async {
    try {
      final url = await PaymentService.requestPaymentReady(
        amount: 1,
        itemName: "현지인 매칭",
        memberId: 1,
      );
      setState(() {
        paymentUrl = url;
        isLoading = false;
      });

      // 웹뷰 로드
      if (paymentUrl != null) {
        _controller.loadRequest(Uri.parse(paymentUrl!));
      }
    } catch (e) {
      print("결제 준비 중 오류: $e");
    }
  }

  ///특정 URL로 이동할 때 결제 승인 처리
  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (request.url.contains('https://yourserver.com/payment/success')) {
      final pgToken = Uri.parse(request.url).queryParameters['pg_token'];
      _approvePayment(pgToken);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  // 결제 승인
  Future<void> _approvePayment(String? pgToken) async {
    if (pgToken == null) return;
    try {
      await PaymentService.requestPaymentApprove(
        pgToken: pgToken,
        memberId: 1,
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("🎉 결제 성공"),
          content: Text("카카오페이 결제가 완료되었습니다."),
        ),
      );
    } catch (e) {
      print("결제 승인 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("카카오페이 결제")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
      // (4) WebViewWidget(controller: _controller)로 웹뷰 표시
          : WebViewWidget(controller: _controller),
    );
  }
}
