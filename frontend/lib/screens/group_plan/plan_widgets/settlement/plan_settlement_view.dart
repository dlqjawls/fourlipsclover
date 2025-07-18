// lib/screens/settlement/plan_widgets/plan_settlement_view.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../providers/settlement_provider.dart';
import '../../../../models/settlement/settlement_model.dart';
import '../../../../widgets/toast_bar.dart';
import '../../settlement_situation_screen.dart';
import 'settlement/../receipt_widget.dart';

class PlanSettlementView extends StatefulWidget {
  final int planId;
  final int groupId;
  final List<dynamic> members; // 멤버 목록 (Member 타입)
  final String? planTitle; // 여행 제목 (옵션)

  const PlanSettlementView({
    Key? key,
    required this.planId,
    required this.groupId,
    required this.members,
    this.planTitle,
  }) : super(key: key);

  @override
  State<PlanSettlementView> createState() => _PlanSettlementViewState();
}

class _PlanSettlementViewState extends State<PlanSettlementView> {
  Settlement? _settlement; // 정산 데이터
  bool _isLoading = true;
  String? _errorMessage;

  // 여행 시작일과 종료일을 저장할 변수
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    
    // Provider의 데이터 변경 감지
    final settlementProvider = Provider.of<SettlementProvider>(
      context, 
      listen: false
    );
    settlementProvider.addListener(_onSettlementProviderChanged);

    // Future.microtask를 사용하여 빌드 후 로드
    Future.microtask(() {
      _loadPlanDates(); // 여행 날짜 로드
      _loadSettlementData(); // 정산 데이터 로드
    });
  }

  void _onSettlementProviderChanged() {
    final settlementProvider = Provider.of<SettlementProvider>(
      context, 
      listen: false
    );
    
    if (settlementProvider.hasDataChanged) {
      _loadSettlementData();
      settlementProvider.resetDataChangedFlag();
    }
  }

  @override
  void dispose() {
    final settlementProvider = Provider.of<SettlementProvider>(
      context, 
      listen: false
    );
    settlementProvider.removeListener(_onSettlementProviderChanged);
    super.dispose();
  }

  // 여행 날짜 로드 메서드
  Future<void> _loadPlanDates() async {
    if (!mounted) return;

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final planDetail = await planProvider.fetchPlanDetail(
        widget.groupId,
        widget.planId,
      );

      if (!mounted) return;

      setState(() {
        _startDate = planDetail.startDate;
        _endDate = planDetail.endDate;
      });
    } catch (e) {
      debugPrint('여행 날짜 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '여행 정보를 불러오는데 실패했습니다.';
        });
      }
    }
  }

  // 정산 데이터 로드 메서드
  Future<void> _loadSettlementData() async {
    if (!mounted) return;

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    try {
      // 정산 상세 정보 조회
      final settlement = await settlementProvider.fetchSettlementDetail(
        widget.planId,
      );
      debugPrint(jsonEncode(settlement));

      if (!mounted) return;

      setState(() {
        _settlement = settlement;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('정산 데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 정보를 불러오는데 실패했습니다.';
        });
      }
    }
  }

  // 정산 생성 메서드
  Future<void> _createSettlement() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    try {
      // 정산 생성 API 호출
      final result = await settlementProvider.createSettlement(widget.planId);

      if (!mounted) return;

      if (result) {
        // 성공 시 정산 데이터 다시 로드
        await _loadSettlementData();

        ToastBar.clover('정산 생성 완료');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 생성에 실패했습니다.';
        });
      }
    } catch (e) {
      debugPrint('정산 생성 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '정산 생성에 실패했습니다: $e';
        });
      }
    }
  }

  // 정산 현황 화면으로 이동 메서드
  Future<void> _navigateToSettlementSituation() async {
    // pushNamed 대신 MaterialPageRoute를 사용
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettlementSituationScreen(
          planId: widget.planId,
          planTitle: widget.planTitle ?? '여행 계획',
        ),
      ),
    );
    
    // 결과가 true이면 정산 데이터 새로고침
    if (result == true) {
      // 약간의 지연을 주어 상태 업데이트를 보장
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadSettlementData();
    }
  }

  // 여행 날짜 포맷 메서드
  String _formatTravelDate() {
    if (_startDate == null || _endDate == null) {
      return '날짜 정보 없음';
    }

    final startFormat = DateFormat('yyyy.MM.dd');
    final endFormat = DateFormat('dd');

    final start = startFormat.format(_startDate!);
    final end = endFormat.format(_endDate!);

    return '$start~$end';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSettlementData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 정산 데이터가 없는 경우 (아직 생성되지 않은 경우)
    if (_settlement == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.mediumGray,
            ),
            const SizedBox(height: 20),
            Text(
              '아직 정산이 생성되지 않았습니다.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '여행 계획에 대한 정산을 생성해보세요!',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _createSettlement,
              icon: const Icon(Icons.add),
              label: const Text('정산 생성하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 정산 상태에 따른 UI 표시
    return Column(
      children: [
        // 정산 상태 표시 박스
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '정산 상태 :   ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  _buildStatusChip(_settlement!.settlementStatus),
                ],
              ),
            ],
          ),
        ),

        // 영수증 또는 비용 없음 메시지
        Expanded(
          child: _settlement!.expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: AppColors.mediumGray,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '등록된 결제 내역이 없습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '여행 중 발생한 비용을 카카오페이로 결제하면\n자동으로 여기에 표시됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // 스크롤 경계에서 튕기는 효과
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ReceiptWidget(
                        settlement: _settlement!,
                        planTitle: widget.planTitle ?? '여행 계획',
                        date: _formatTravelDate(),
                        planId: widget.planId,
                        groupId: widget.groupId,
                        onSettlementRequested: _loadSettlementData,
                      ),
                    ),
                  ),
                ),
        ),

        // 정산 현황 버튼 (정산이 이미 요청된 경우만 표시)
        if (_settlement!.settlementStatus != SettlementStatus.PENDING)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _navigateToSettlementSituation,
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('정산 현황 보기', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 정산 상태 칩 위젯
  Widget _buildStatusChip(SettlementStatus status) {
    String text;
    Color color;

    switch (status) {
      case SettlementStatus.PENDING:
        text = '진행 중';
        color = Colors.orange;
        break;
      case SettlementStatus.IN_PROGRESS:
        text = '정산 요청됨';
        color = Colors.blue;
        break;
      case SettlementStatus.COMPLETED:
        text = '완료됨';
        color = Colors.green;
        break;
      case SettlementStatus.CANCELED:
        text = '취소됨';
        color = Colors.red;
        break;
      default:
        text = '알 수 없음';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}