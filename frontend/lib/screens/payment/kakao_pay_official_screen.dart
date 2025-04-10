import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/payment/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'payment_success_screen.dart';
import '../../services/matching/matching_approve.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KakaoPayOfficialScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final Map<String, dynamic> matchingInfo;

  const KakaoPayOfficialScreen({
    Key? key,
    required this.matchData,
    required this.matchingInfo,
  }) : super(key: key);

  @override
  State<KakaoPayOfficialScreen> createState() => _KakaoPayOfficialScreenState();
}

class _KakaoPayOfficialScreenState extends State<KakaoPayOfficialScreen> {
  final _matchingApproveService = MatchingApproveService();
  late final WebViewController _controller;
  bool isLoading = true;
  String? paymentUrl;
  String? _tid;
  String? _orderId;

  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) throw Exception('API_BASE_URL이 .env 파일에 정의되지 않았습니다.');
    return url;
  }

  @override
  void initState() {
    super.initState();
    print('matchData: ${widget.matchData}');
    print('matchingInfo: ${widget.matchingInfo}');

    _controller =
        WebViewController()
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final amount = widget.matchData['total_amount'];

      if (userId == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      if (amount == null) {
        throw Exception('결제 금액 정보가 없습니다.');
      }

      // amount를 int로 변환
      final amountInt = amount is String ? int.parse(amount) : amount as int;

      print('=== 결제 정보 시작 ===');
      print('userId: $userId');
      print('amount: $amountInt');

      final result = await PaymentService.requestPaymentReady(
        userId: userId,
        itemName: '현지인 매칭',
        quantity: '1',
        totalAmount: amountInt,
      );

      setState(() {
        _tid = result.tid;
        _orderId = result.orderId;
        paymentUrl = result.redirectUrl;
        isLoading = false;
      });

      if (paymentUrl != null) {
        await _controller.loadRequest(Uri.parse(paymentUrl!));
      }
    } catch (e) {
      print("결제 준비 중 오류: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('결제 준비 중 오류가 발생했습니다: $e')));
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

    // 결제 실패 URL 처리 추가
    if (url.contains('/api/payment/fail')) {
      print("결제 실패 URL 감지됨: $url");
      _handlePaymentFailure(url);
      return NavigationDecision.prevent;
    }

    // URL 패턴 수정
    if (url.contains('/api/match/approve')) {
      final uri = Uri.parse(url);
      final pgToken = uri.queryParameters['pg_token'];

      print('pgToken: $pgToken');
      print('tid: $_tid');
      print('orderId: $_orderId');

      if (pgToken != null && _tid != null && _orderId != null) {
        approveMatching(tid: _tid!, pgToken: pgToken, orderId: _orderId!);
      } else {
        print("필요한 파라미터 없음. JS 추출 시도.");
        _tryExtractPgToken();
      }

      return NavigationDecision.prevent;
    }

    // pg_token 체크 로직도 수정
    if (url.contains("pg_token")) {
      final uri = Uri.parse(url);
      final pgToken = uri.queryParameters['pg_token'];

      if (pgToken != null && _tid != null && _orderId != null) {
        approveMatching(tid: _tid!, pgToken: pgToken, orderId: _orderId!);
        return NavigationDecision.prevent;
      }

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
          final newUrl =
              url.replaceFirst('intent://', '$scheme://').split('#')[0];
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
      final result = await _controller.runJavaScriptReturningResult(
        "window.location.href",
      );
      final currentUrl = result.toString().replaceAll('"', '');
      final uri = Uri.parse(currentUrl);
      final pgToken = uri.queryParameters['pg_token'];

      print("JS 추출 URL: $currentUrl");
      print("추출된 pg_token: $pgToken, tid: $_tid, orderId: $_orderId");

      // 응답 데이터에서 pg_token 찾기 시도
      if (pgToken == null) {
        final approvalDataScript = await _controller
            .runJavaScriptReturningResult("document.body.textContent");
        final approvalData = approvalDataScript.toString();
        if (approvalData.contains("approval_redirect_params")) {
          final regex = RegExp(r'"pg_token":\s*"([^"]+)"');
          final match = regex.firstMatch(approvalData);
          if (match != null) {
            final extractedPgToken = match.group(1);
            if (extractedPgToken != null && _tid != null && _orderId != null) {
              await approveMatching(
                tid: _tid!,
                pgToken: extractedPgToken,
                orderId: _orderId!,
              );
              return;
            }
          }
        }
      }

      if (pgToken != null && _tid != null && _orderId != null) {
        await approveMatching(tid: _tid!, pgToken: pgToken, orderId: _orderId!);
      } else {
        print("JS에서도 필요한 값이 없음.");
      }
    } catch (e) {
      print("JS URL 추출 중 오류: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('결제 처리 중 오류가 발생했습니다: $e')));
    }
  }

  // 결제 실패 처리 함수 추가
  void _handlePaymentFailure(String url) {
    try {
      // URL에서 실패 이유 추출 시도
      final uri = Uri.parse(url);
      final errorMsg = uri.queryParameters['message'] ?? '알 수 없는 오류';
      final errorCode = uri.queryParameters['code'] ?? '';

      print("결제 실패 정보 - 코드: $errorCode, 메시지: $errorMsg");

      if (!mounted) return;

      // 결제 실패 알림 표시 후 화면 닫기
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('결제 실패: $errorMsg')));

      // 실패 정보를 가지고 화면 닫기
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop({
            'error': 'payment_failed',
            'message': errorMsg,
            'code': errorCode,
          });
        }
      });
    } catch (e) {
      print("결제 실패 처리 중 오류: $e");
      if (mounted) {
        Navigator.of(context).pop({'error': '결제 처리 중 오류가 발생했습니다'});
      }
    }
  }

  Future<void> approveMatching({
    required String tid,
    required String pgToken,
    required String orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final amount = widget.matchData['total_amount'];

      if (userId == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      print('=== 매칭 데이터 디버깅 ===');
      print('전체 matchingInfo: ${widget.matchingInfo}');
      print('전체 guide 정보: ${widget.matchingInfo['guide']}');
      print('모든 키: ${widget.matchingInfo.keys.toList()}');

      // 안전한 형변환을 위한 도우미 함수
      int safeParseInt(dynamic value, {int defaultValue = 0}) {
        if (value == null) return defaultValue;
        try {
          if (value is int) return value;
          if (value is String) return int.parse(value);
          return defaultValue;
        } catch (e) {
          print('정수 변환 실패 ($value): $e');
          return defaultValue;
        }
      }

      final amountInt = safeParseInt(amount, defaultValue: 0);
      if (amountInt <= 0) {
        throw Exception('유효하지 않은 결제 금액: $amount');
      }

      final matchingInfo = widget.matchingInfo;
      final guide = matchingInfo['guide'] as Map<String, dynamic>? ?? {};

      // guide.memberId가 없는 경우를 위한 처리
      final guideMemberId = guide['memberId'] ?? guide['id'];
      if (guideMemberId == null) {
        throw Exception('가이드 회원 ID를 찾을 수 없습니다.');
      }
      final guideMemberIdInt = safeParseInt(guideMemberId);

      // 그룹 ID 추출 또는 기본값 설정
      int groupId = 1; // 기본값으로 초기화

      debugPrint('일반 그룹ID 확인: ${matchingInfo['groupId']}');
      debugPrint('중첩 그룹 구조: ${matchingInfo['selectedGroup']}');

      // 그룹 ID 추출 간소화
      if (matchingInfo.containsKey('groupId') &&
          matchingInfo['groupId'] != null) {
        groupId = safeParseInt(matchingInfo['groupId']);
        debugPrint('groupId 직접 찾음: $groupId');
      } else if (matchingInfo.containsKey('selectedGroup') &&
          matchingInfo['selectedGroup'] is Map &&
          matchingInfo['selectedGroup']?['groupId'] != null) {
        groupId = safeParseInt(matchingInfo['selectedGroup']['groupId']);
        debugPrint('selectedGroup.groupId에서 찾음: $groupId');
      }

      // 그룹 ID가 0이면 1로 변환하지 않음 (0은 '나혼자 산다'의 유효한 값)
      debugPrint('그룹ID 최종 확인: $groupId');

      // 유효한 그룹 ID인지 확인 (0도 유효한 값으로 처리)
      if (groupId < 0) {
        debugPrint('경고: 추출된 groupId가 유효하지 않음($groupId), 기본값 0 사용');
        groupId = 0; // 나혼자 산다로 기본 설정
      }

      debugPrint('=== 최종 그룹 ID: $groupId ===');
      debugPrint('matchingInfo 키 목록: ${matchingInfo.keys.toList()}');

      // 태그 ID 안전하게 추출
      List<int> tagIds = [];
      try {
        if (matchingInfo.containsKey('tagIds') &&
            matchingInfo['tagIds'] is List) {
          final tagIdsDynamic = matchingInfo['tagIds'] as List<dynamic>;
          tagIds = tagIdsDynamic.map((e) => safeParseInt(e)).toList();
        }
      } catch (e) {
        print('태그 ID 파싱 오류: $e');
        print('원본 태그 데이터: ${matchingInfo['tagIds']}');
      }

      final regionId = safeParseInt(matchingInfo['regionId']);

      print('=== 매칭 승인 정보 ===');
      print('amount: $amountInt');
      print('tagIds: $tagIds');
      print('regionId: $regionId');
      print('guideMemberId: $guideMemberIdInt');
      print('groupId: $groupId');

      // 필수 값 검증
      if (regionId <= 0) {
        throw Exception('유효하지 않은 지역 ID: $regionId');
      }

      if (guideMemberIdInt <= 0) {
        throw Exception('유효하지 않은 가이드 ID: $guideMemberIdInt');
      }

      await _matchingApproveService.approveMatching(
        tid: tid,
        pgToken: pgToken,
        orderId: orderId,
        amount: amountInt.toString(),
        tagIds: tagIds,
        regionId: regionId,
        guideMemberId: guideMemberIdInt,
        groupId: groupId, // 추출한 그룹 ID 전달
        transportation: matchingInfo['selectedTransport']?.toString() ?? '',
        foodPreference: matchingInfo['selectedFoodCategory']?.toString() ?? '',
        tastePreference: matchingInfo['selectedTaste']?.toString() ?? '',
        requirements: matchingInfo['request']?.toString() ?? '',
        startDate: matchingInfo['startDate']?.toString() ?? '',
        endDate: matchingInfo['endDate']?.toString() ?? '',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaymentSuccessScreen(
                itemName: '현지인 매칭',
                amount: amountInt,
                tid: tid,
              ),
        ),
      );
    } catch (e) {
      print("매칭 승인 오류: $e");
      print("매칭 정보: ${widget.matchingInfo}");
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('매칭 승인 중 오류가 발생했습니다: $e')));

      // 오류 정보와 함께 화면 닫기
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop({'error': e.toString()});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _controller),
    );
  }
}
