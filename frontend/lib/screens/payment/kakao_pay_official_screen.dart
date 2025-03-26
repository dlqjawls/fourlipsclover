import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'payment_success_screen.dart';

class KakaoPayOfficialScreen extends StatefulWidget {
  const KakaoPayOfficialScreen({super.key});

  @override
  State<KakaoPayOfficialScreen> createState() => _KakaoPayOfficialScreenState();
}

class _KakaoPayOfficialScreenState extends State<KakaoPayOfficialScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  String? paymentUrl;

  // 새로 추가된 상태값: tid, orderId 저장용
  String? _tid;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _handleNavigation(request),
        ),
      );
    _initPayment();
  }

  Future<void> _initPayment() async {
    try {
      final result = await PaymentService.requestPaymentReady(
        userId: '3963528811',
        itemName: '현지인 매칭',
        quantity: '1',
        totalAmount: 2000,
      );

      // 저장
      _tid = result.tid;
      _orderId = result.orderId;
      paymentUrl = result.redirectUrl;

      setState(() => isLoading = false);

      if (paymentUrl != null) {
        _controller.loadRequest(Uri.parse(paymentUrl!));
      }
    } catch (e) {
      print("결제 준비 중 오류: $e");
      setState(() => isLoading = false);
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    print("이동 URL: $url");

    if (url.startsWith('intent://')) {
      _launchIntentUrl(url);
      return NavigationDecision.prevent;
    }

    // 승인 리디렉션 감지
    if (url.startsWith('https://fourlipsclover.duckdns.org/api/payment/approve')) {
      final uri = Uri.parse(url);
      final pgToken = uri.queryParameters['pg_token'];

      print('pgToken: $pgToken');
      print('tid: $_tid');
      print('orderId: $_orderId');

      if (pgToken != null && _tid != null && _orderId != null) {
        _approvePayment(
          tid: _tid!,
          pgToken: pgToken,
          orderId: _orderId!,
          userId: '3963528811',
          amount: 2000,
        );
      } else {
        print("필요한 파라미터 없음. JS 추출 시도.");
        _tryExtractPgToken();
      }

      return NavigationDecision.prevent;
    }

    if (url.contains("pg_token")) {
      print("pg_token 포함된 URL 탐지됨. JS 추출 시도.");
      _tryExtractPgToken();
    }

    return NavigationDecision.navigate;
  }

  void _launchIntentUrl(String url) async {
    try {
      if (Platform.isAndroid) {
        final regex = RegExp(r';scheme=([^;]+);');
        final match = regex.firstMatch(url);
        if (match != null) {
          final scheme = match.group(1);
          final newUrl = url.replaceFirst('intent://', '$scheme://').split('#')[0];
          final parsedUrl = Uri.parse(newUrl);
          if (await canLaunchUrl(parsedUrl)) {
            await launchUrl(parsedUrl);
          } else {
            final intent = AndroidIntent(action: 'action_view', data: newUrl);
            await intent.launch();
          }
        } else {
          throw Exception('intent URL 파싱 실패');
        }
      } else {
        final parsedUrl = Uri.parse(url);
        if (await canLaunchUrl(parsedUrl)) {
          await launchUrl(parsedUrl);
        } else {
          print('실행 불가 URL: $url');
        }
      }
    } catch (e) {
      print('intent 실행 오류: $e');
    }
  }

  Future<void> _tryExtractPgToken() async {
    try {
      final result = await _controller.runJavaScriptReturningResult("window.location.href");
      final currentUrl = result.toString().replaceAll('"', '');
      final uri = Uri.parse(currentUrl);
      final pgToken = uri.queryParameters['pg_token'];

      print("JS 추출 URL: $currentUrl");
      print("추출된 pg_token: $pgToken, tid: $_tid, orderId: $_orderId");

      if (pgToken != null && _tid != null && _orderId != null) {
        await _approvePayment(
          tid: _tid!,
          pgToken: pgToken,
          orderId: _orderId!,
          userId: '3963528811',
          amount: 2000,
        );
      } else {
        print("JS에서도 필요한 값이 없음.");
      }
    } catch (e) {
      print("JS URL 추출 중 오류: $e");
    }
  }

  Future<void> _approvePayment({
    required String tid,
    required String pgToken,
    required String orderId,
    required String userId,
    required int amount,
  }) async {
    try {
      await PaymentService.requestPaymentApprove(
        tid: tid,
        pgToken: pgToken,
        orderId: orderId,
        userId: userId,
        amount: amount,
      );
      if (!mounted) return;

      // 결제 완료 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            itemName: '현지인 매칭',
            amount: amount,
            orderId: orderId,
          ),
        ),
      );
    } catch (e) {
      print("결제 승인 오류: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
