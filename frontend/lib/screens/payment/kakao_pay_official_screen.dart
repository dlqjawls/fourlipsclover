import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';




class KakaoPayOfficialScreen extends StatefulWidget {
  const KakaoPayOfficialScreen({super.key});

  @override
  State<KakaoPayOfficialScreen> createState() => _KakaoPayOfficialScreenState();
}

class _KakaoPayOfficialScreenState extends State<KakaoPayOfficialScreen> {
  late final WebViewController _controller;

  bool isLoading = true;
  String? paymentUrl;

  @override
  void initState() {
    super.initState();

    // 안드로이드 장치(또는 에뮬레이터)에서 WebView.platform 지정 (선택적)
    // if (Platform.isAndroid) {
    //   WebView.platform = AndroidWebView();
    // }

    // (1) WebViewController 생성
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            return _handleNavigation(request);
          },
        ),
      );

    // (2) 결제 준비 요청
    _initPayment();
  }

  /// 서버에 결제 준비 요청 (PaymentService.requestPaymentReady)
  Future<void> _initPayment() async {
    try {
      // 아래 userId, itemName, quantity, totalAmount는
      final redirectUrl = await PaymentService.requestPaymentReady(
        userId: '3963528811',
        itemName: '현지인 매칭',
        quantity: '1',
        totalAmount: 2000, // 예: 1000원
      );

      setState(() {
        paymentUrl = redirectUrl;
        isLoading = false;
      });

      // 결제 페이지로 로드
      if (paymentUrl != null) {
        _controller.loadRequest(Uri.parse(paymentUrl!));
      }
    } catch (e) {
      print("결제 준비 중 오류: $e");
      setState(() => isLoading = false);
    }
  }

  /// 웹뷰에서 특정 URL로 넘어갈 때 결제 승인
  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    // 예: 카카오 결제가 완료되면 서버가 yourserver.com/payment/success 로 리다이렉트
    if (url.startsWith('intent://')) {
      _launchIntentUrl(url);
      return NavigationDecision.prevent;
    }

    if (url.contains('yourserver.com/payment/success')) {
      // 예) https://yourserver.com/payment/success?tid=xxx&pg_token=xxx&orderId=xxx
      final uri = Uri.parse(url);
      final tid     = uri.queryParameters['tid'];
      final pgToken = uri.queryParameters['pg_token'];
      final orderId = uri.queryParameters['orderId'];

      if (tid != null && pgToken != null && orderId != null) {
        _approvePayment(
          tid: tid,
          pgToken: pgToken,
          orderId: orderId,
          userId: '3963528811', // 실제 유저 ID
          amount: 2000,
        );
      }
      // 리다이렉트 막기
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _launchIntentUrl(String url) async {
    try {
      if (Platform.isAndroid) {
        // intent:// URL에서 'scheme' 값을 추출
        final regex = RegExp(r';scheme=([^;]+);');
        final match = regex.firstMatch(url);
        if (match != null) {
          final scheme = match.group(1); // 예: "kakaotalk"
          // intent:// 를 해당 스킴 URL로 변환
          // #Intent; 이후의 정보는 제거
          final newUrl = url.replaceFirst('intent://', '$scheme://').split('#')[0];
          final parsedUrl = Uri.parse(newUrl);
          if (await canLaunchUrl(parsedUrl)) {
            await launchUrl(parsedUrl);
          } else {
            // 만약 launchUrl로 열리지 않으면 android_intent_plus 사용
            final intent = AndroidIntent(
              action: 'action_view',
              data: newUrl,
            );
            await intent.launch();
          }
        } else {
          throw Exception('intent URL 파싱 실패: scheme 정보를 찾을 수 없습니다.');
        }
      } else {
        final parsedUrl = Uri.parse(url);
        if (await canLaunchUrl(parsedUrl)) {
          await launchUrl(parsedUrl);
        } else {
          print('❌ 실행할 수 없는 URL: $url');
        }
      }
    } catch (e) {
      print('intent 실행 오류: $e');
    }
  }


  /// 결제 승인
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

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("결제 성공"),
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
      // appBar: AppBar(
      //   title: const Text("카카오페이 결제"),
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
