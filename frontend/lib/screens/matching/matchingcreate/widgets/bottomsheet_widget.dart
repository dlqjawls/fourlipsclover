import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:intl/intl.dart';
import 'package:frontend/screens/payment/kakao_pay_official_screen.dart';
import 'package:frontend/services/matching/matching_approve.dart';

class MatchingConfirmBottomSheet extends StatefulWidget {
  final Group? selectedGroup;
  final String? selectedTransport;
  final String? selectedFoodCategory;
  final String? selectedTaste;
  final String request;
  final Map<String, dynamic> guide;
  final int regionId;
  final List<int> tagIds;
  final String startDate;
  final String endDate;
  final Map<String, dynamic> matchData;

  const MatchingConfirmBottomSheet({
    Key? key,
    required this.selectedGroup,
    required this.selectedTransport,
    required this.selectedFoodCategory,
    required this.selectedTaste,
    required this.request,
    required this.guide,
    required this.regionId,
    required this.tagIds,
    required this.startDate,
    required this.endDate,
    required this.matchData,
  }) : super(key: key);

  @override
  State<MatchingConfirmBottomSheet> createState() =>
      _MatchingConfirmBottomSheetState();
}

class _MatchingConfirmBottomSheetState
    extends State<MatchingConfirmBottomSheet> {
  bool _isLoading = false;
  final MatchingApproveService _matchingApproveService =
      MatchingApproveService();
  final formatter = NumberFormat('#,###');

  // 결제 데이터 검증
  Map<String, String> validatePaymentData() {
    final mobileUrl = widget.matchData['next_redirect_mobile_url'] as String?;
    final appUrl = widget.matchData['android_app_scheme'] as String?;
    final orderId = widget.matchData['orderId'] as String?;
    final tid = widget.matchData['tid'] as String?;
    final totalAmount = widget.matchData['total_amount']?.toString();

    if (mobileUrl == null ||
        appUrl == null ||
        orderId == null ||
        tid == null ||
        totalAmount == null) {
      throw Exception('필수 결제 정보가 누락되었습니다.');
    }

    return {
      'mobileUrl': mobileUrl,
      'appUrl': appUrl,
      'orderId': orderId,
      'tid': tid,
      'totalAmount': totalAmount,
    };
  }

  // 결제 프로세스 처리
  Future<void> _handlePayment() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final paymentData = validatePaymentData();
      debugPrint('결제 정보 시작 ====');
      debugPrint('결제 URL: ${paymentData['mobileUrl']}');
      debugPrint('앱 스킴: ${paymentData['appUrl']}');
      debugPrint('주문 ID: ${paymentData['orderId']}');
      debugPrint('TID: ${paymentData['tid']}');
      debugPrint('총액: ${paymentData['totalAmount']}');
      debugPrint('가이드 정보: ${widget.guide}');

      if (!mounted) return;

      final result = await _processPayment(paymentData);
      await _handlePaymentResult(result, paymentData);
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 결제 진행
  Future<Map<String, dynamic>?> _processPayment(
    Map<String, String> paymentData,
  ) async {
    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute<Map<String, dynamic>>(
        builder:
            (context) => KakaoPayOfficialScreen(
              matchData: {
                'next_redirect_mobile_url': paymentData['mobileUrl'],
                'android_app_scheme': paymentData['appUrl'],
                'orderId': paymentData['orderId'],
                'tid': paymentData['tid'],
                'total_amount': paymentData['totalAmount'],
              },
              matchingInfo: _buildMatchingInfo(),
            ),
      ),
    );
  }

  // 매칭 정보 구성
  Map<String, dynamic> _buildMatchingInfo() {
    return {
      'guide': {
        'id': widget.guide['id']?.toString() ?? '',
        'memberId': widget.guide['memberId']?.toString() ?? '',
        'name': widget.guide['name']?.toString() ?? '',
        'iconColor': widget.guide['iconColor'],
        'imageAsset': widget.guide['imageAsset'],
      },
      'regionId': widget.regionId,
      'tagIds': widget.tagIds,
      'selectedTransport': widget.selectedTransport ?? '',
      'selectedFoodCategory': widget.selectedFoodCategory ?? '',
      'selectedTaste': widget.selectedTaste ?? '',
      'request': widget.request,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
    };
  }

  // 결제 결과 처리
  Future<void> _handlePaymentResult(
    Map<String, dynamic>? result,
    Map<String, String> paymentData,
  ) async {
    if (result == null) return;

    if (result['pg_token'] != null) {
      debugPrint('PG Token 수신: ${result['pg_token']}');

      await _matchingApproveService.approveMatching(
        tid: paymentData['tid']!,
        pgToken: result['pg_token'],
        orderId: paymentData['orderId']!,
        amount: paymentData['totalAmount']!,
        // amount: int.parse(paymentData['totalAmount']!),
        tagIds: widget.tagIds,
        regionId: widget.regionId,
        guideMemberId: widget.guide['memberId'],
        transportation: widget.selectedTransport ?? '',
        foodPreference: widget.selectedFoodCategory ?? '',
        tastePreference: widget.selectedTaste ?? '',
        requirements: widget.request,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      _showSuccessMessage();
    } else if (result['error'] != null) {
      throw Exception(result['error']);
    }
  }

  // 에러 처리
  void _handleError(dynamic error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('결제 중 오류가 발생했습니다: $error')));
    debugPrint('결제 오류: $error');
  }

  // 성공 메시지 표시
  void _showSuccessMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('매칭 신청이 완료되었습니다.')));
  }

  // UI 구성 요소
  Widget _buildReceiptItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
          ),
          Text(
            value ?? '-',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.guide['profileUrl']),
          radius: 24,
          backgroundColor: Colors.grey[200],
          onBackgroundImageError: (e, s) {
            debugPrint('이미지 로드 실패: $e');
          },
          child:
              widget.guide['profileUrl'].isEmpty
                  ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                  : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.guide['name']} 가이드',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '맛있는 여행 메이트',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child:
          _isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text(
                '결제하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = int.parse(widget.matchData['total_amount'].toString());
    final orderId = widget.matchData['orderId'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '매칭 신청 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGuideInfo(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _buildReceiptItem('주문번호', orderId),
          _buildReceiptItem('그룹', widget.selectedGroup?.name ?? '나혼자 산다'),
          _buildReceiptItem('이동 수단', widget.selectedTransport),
          _buildReceiptItem('음식 종류', widget.selectedFoodCategory),
          _buildReceiptItem('선호하는 맛', widget.selectedTaste),
          _buildReceiptItem('여행 시작일', widget.startDate),
          _buildReceiptItem('여행 종료일', widget.endDate),
          if (widget.request.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '요청사항',
              style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.verylightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.request, style: const TextStyle(fontSize: 14)),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '결제 금액',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                '${formatter.format(totalAmount)}원',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentButton(),
        ],
      ),
    );
  }
}
