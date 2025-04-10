import 'package:flutter/material.dart';
import '../../services/payment/payment_service.dart';
import 'payment_history_screen.dart';
import '../../config/theme.dart';
import '../../screens/matching/matching.dart';
import 'package:provider/provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/toast_bar.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String itemName;
  final int amount;
  final String tid;

  const PaymentSuccessScreen({
    Key? key,
    required this.itemName,
    required this.amount,
    required this.tid,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String? _status;

  @override
  void initState() {
    super.initState();
    print("✅ PaymentSuccessScreen initState 호출됨");
    _loadPaymentStatus();
  }

  void _loadPaymentStatus() async {
    try {
      final status = await PaymentService.getPaymentStatusByTid(widget.tid);
      setState(() {
        _status = status;
      });
    } catch (e) {
      print('상태 조회 실패: $e');
      setState(() {
        _status = null;
      });
    }
  }

  // 결제 취소 처리
  void _cancelPayment() async {
    try {
      await PaymentService.requestPaymentCancel(
        tid: widget.tid,
        cancelAmount: widget.amount,
        cancelTaxFreeAmount: 0,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('결제 취소'),
          content: const Text('결제가 정상적으로 취소되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫고
                _navigateToMatching(); // ✅ 매칭 목록 이동 유지
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ 결제 취소 실패: $e');
      ToastBar.clover('결제가 취소되었습니다.');
    }
  }


  void _navigateToMatching() {
    // 모든 화면을 제거하고 메인 화면으로 이동한 후 매칭 화면으로 이동
    Navigator.of(context).popUntil((route) => route.isFirst); // 메인 화면까지 pop
    Navigator.pushNamed(context, '/matching'); // 매칭 화면으로 이동
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AppProvider>(context, listen: false).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 완료'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // 상단 성공 표시 및 정보
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '${widget.itemName} 결제가 완료되었습니다.',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.payment,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.amount}원',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_status == 'CANCELED')
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '취소 완료',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 섹션
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // 상단 버튼들 (결제 내역 / 결제 취소)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentHistoryListScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.receipt_long, size: 20, color: Colors.white),
                            label: const Text('결제 내역'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _status == 'CANCELED'
                              ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '취소완료',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : ElevatedButton.icon(
                            onPressed: _cancelPayment,
                            icon: const Icon(Icons.cancel, size: 20),
                            label: const Text('결제 취소'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 매칭 목록 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToMatching,
                        icon: const Icon(Icons.list, size: 20, color: Colors.white),
                        label: const Text(
                          '매칭 목록으로 이동',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}