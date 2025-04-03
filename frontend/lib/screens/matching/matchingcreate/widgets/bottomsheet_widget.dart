import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      final mobileUrl = widget.matchData['next_redirect_mobile_url'];
      final appUrl = widget.matchData['android_app_scheme'];

      debugPrint('결제 URL: $mobileUrl');
      debugPrint('앱 스킴: $appUrl');

      if (await canLaunchUrl(Uri.parse(appUrl))) {
        await launchUrl(Uri.parse(appUrl));
      } else if (await canLaunchUrl(Uri.parse(mobileUrl))) {
        await launchUrl(Uri.parse(mobileUrl));
      } else {
        throw '결제를 시작할 수 없습니다.';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('결제 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final totalAmount = int.parse(widget.matchData['total_amount'].toString());
    final orderId = widget.matchData['orderId'] as String;
    final mobileUrl = widget.matchData['next_redirect_mobile_url'] as String;

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

          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.guide['iconColor'],
                radius: 24,
                child: Icon(
                  widget.guide['imageAsset'],
                  color: Colors.white,
                  size: 24,
                ),
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
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          _buildReceiptItem('주문번호', orderId),
          _buildReceiptItem('그룹', widget.selectedGroup?.name ?? '나혼자 산다'),
          _buildReceiptItem('이동 수단', widget.selectedTransport ?? '-'),
          _buildReceiptItem('음식 종류', widget.selectedFoodCategory ?? '-'),
          _buildReceiptItem('선호하는 맛', widget.selectedTaste ?? '-'),
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

          ElevatedButton(
            onPressed: _isLoading ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          ),
        ],
      ),
    );
  }
}
