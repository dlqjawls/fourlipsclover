// lib/screens/settlement/settlement_situation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/clover_loading_spinner.dart';
import '../../providers/settlement_provider.dart';
import '../../models/settlement/settlement_model.dart';
import '../../models/settlement/settlement_situation_model.dart';
import '../../models/settlement/settlement_transaction_response.dart';
import '../../models/settlement/transaction_types.dart';
import '../../config/theme.dart';
import '../../widgets/toast_bar.dart';
import '../../widgets/custom_switch.dart';

class SettlementSituationScreen extends StatefulWidget {
  final int planId;
  final String planTitle;

  const SettlementSituationScreen({
    Key? key,
    required this.planId,
    required this.planTitle,
  }) : super(key: key);

  @override
  State<SettlementSituationScreen> createState() =>
      _SettlementSituationScreenState();
}

class _SettlementSituationScreenState extends State<SettlementSituationScreen> {
  final currencyFormatter = NumberFormat('#,###', 'ko_KR');
  bool _isLoading = false;
  bool _showOnlyPending = false;
  bool _isStateChanged = false; // 상태 변경 여부를 추적하는 변수
  late SettlementProvider _settlementProvider;

  @override
  void initState() {
    super.initState();
    // Provider 초기화 (dispose에서 안전하게 사용하기 위해)
    _settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    // 직접 호출 대신 스케줄링
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _settlementProvider.fetchSettlementSituation(widget.planId);

      // 정산 상세 정보도 함께 새로고침
      await _settlementProvider.fetchSettlementDetail(widget.planId);
    } catch (e) {
      if (mounted) {
        ToastBar.clover('정산 현황 불러오기 실패');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeTransaction(int transactionId) async {
  setState(() {
    _isLoading = true;
  });

  try {
    final result = await _settlementProvider.completeTransaction(
      widget.planId,
      transactionId,
    );
    // Provider 내부에서 이미 상태 변경 플래그 설정됨

    if (result && mounted) {
      // 상태 변경 플래그를 true로 설정
      _isStateChanged = true;
      ToastBar.clover('정산완료 처리 완료');

      // 정산 상세 정보도 즉시 새로고침
      await _settlementProvider.fetchSettlementDetail(widget.planId);
    }
  } catch (e) {
    if (mounted) {
      ToastBar.clover('정산완료 처리 실패');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼 처리 - 상태가 변경되었으면 결과 전달
        if (_isStateChanged) {
          Navigator.pop(context, true);
          return false; // WillPopScope에서는 false를 반환하면 직접 pop 처리
        }
        return true; // 상태가 변경되지 않았으면 일반적인 뒤로가기 처리
      },
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: const Text(
              '정산 현황',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchData,
                tooltip: '새로고침',
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // 직접 뒤로가기 처리 - 상태 변경 반영
                Navigator.pop(context, _isStateChanged);
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _fetchData,
            color: AppColors.primary,
            child: Consumer<SettlementProvider>(
              builder: (context, settlementProvider, _) {
                final situations = settlementProvider
                    .getSettlementSituationForPlan(widget.planId);

                if (situations == null || situations.isEmpty) {
                  return _buildEmptyState();
                }

                // 첫 번째 상황 정보 사용 (목록에 여러 개가 있을 수 있음)
                final situation = situations.first;

                // 모든 거래가 완료 상태인지 확인
                bool allTransactionsCompleted = situation
                    .settlementTransactionResponses
                    .every(
                      (t) => t.transactionStatus == TransactionStatus.COMPLETED,
                    );

                // 이미 정산 상태가 COMPLETED가 아니고, 모든 거래가 완료되었다면
                // 정산 상태도 자동으로 완료 상태로 업데이트 (이 부분은 백엔드 API에 맞게 수정 필요)
                if (allTransactionsCompleted &&
                    situation.settlementStatus != SettlementStatus.COMPLETED &&
                    situation.settlementTransactionResponses.isNotEmpty) {
                  // 상태 변경 플래그 설정만 하고 API 호출 없이 진행
                  _isStateChanged = true;

                  if (mounted) {
                    ToastBar.clover('모든 정산이 완료되었습니다');
                  }
                }

                return Column(
                  children: [
                    _buildHeader(situation),
                    _buildFilterBar(),
                    Expanded(child: _buildTransactionList(situation)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            '정산 현황이 없습니다.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래로 당겨서 새로고침 하세요.',
            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('새로고침', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            '미완료 항목만 보기',
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
          const SizedBox(width: 8),
          CustomSwitch(
            value: _showOnlyPending,
            onChanged: (value) {
              setState(() {
                _showOnlyPending = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SettlementSituationResponse situation) {
    final statusText = _settlementProvider.getSettlementStatusText(
      situation.settlementStatus,
    );

    int totalTransactions = situation.settlementTransactionResponses.length;
    int completedTransactions =
        situation.settlementTransactionResponses
            .where((t) => t.transactionStatus == TransactionStatus.COMPLETED)
            .length;
    double progressPercentage =
        totalTransactions > 0
            ? (completedTransactions / totalTransactions) * 100
            : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.planTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총무',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    situation.treasurerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    situation.settlementStatus,
                  ).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기간: ${DateFormat('yyyy.MM.dd').format(situation.startDate)} - ${DateFormat('yyyy.MM.dd').format(situation.endDate)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '$completedTransactions/$totalTransactions 완료',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(SettlementSituationResponse situation) {
    // 거래 상태별로 정렬 (진행 중인 거래가 먼저)
    final transactions = [...situation.settlementTransactionResponses];

    // 상태별 우선순위에 따라 정렬
    transactions.sort((a, b) {
      // 상태별 우선순위: PENDING, FAILED, COMPLETED, CANCELED
      getStatusPriority(TransactionStatus status) {
        switch (status) {
          case TransactionStatus.PENDING:
            return 0;
          case TransactionStatus.FAILED:
            return 1;
          case TransactionStatus.COMPLETED:
            return 2;
          case TransactionStatus.CANCELED:
            return 3;
        }
      }

      return getStatusPriority(
        a.transactionStatus,
      ).compareTo(getStatusPriority(b.transactionStatus));
    });

    // 필터 적용
    if (_showOnlyPending) {
      transactions.removeWhere(
        (t) => t.transactionStatus != TransactionStatus.PENDING,
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showOnlyPending ? Icons.done_all : Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyPending ? '미완료된 정산 내역이 없습니다!' : '정산 거래 내역이 없습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isPending =
            transaction.transactionStatus == TransactionStatus.PENDING;
        final statusText = _settlementProvider.getTransactionStatusText(
          transaction.transactionStatus,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _getTransactionStatusColor(
                transaction.transactionStatus,
              ).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.verylightGray,
                      radius: 20,
                      child: Text(
                        transaction.payer.nickname?.substring(0, 1) ??
                            transaction.payer.name?.substring(0, 1) ??
                            '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.payer.nickname ??
                            transaction.payer.name ??
                            '사용자',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTransactionStatusColor(
                          transaction.transactionStatus,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getTransactionStatusColor(
                            transaction.transactionStatus,
                          ).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getStatusIcon(transaction.transactionStatus) ??
                              const SizedBox.shrink(),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _getTransactionStatusColor(
                                transaction.transactionStatus,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.mediumGray,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      radius: 20,
                      child: Text(
                        transaction.payee.nickname?.substring(0, 1) ??
                            transaction.payee.name?.substring(0, 1) ??
                            '총',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.payee.nickname ??
                            transaction.payee.name ??
                            '총무',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currencyFormatter.format(transaction.cost)}원',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.mediumGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '요청: ${DateFormat('yyyy.MM.dd').format(transaction.createdAt ?? DateTime.now())}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                        if (transaction.sentAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '완료: ${DateFormat('yyyy.MM.dd').format(transaction.sentAt!)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (isPending &&
                        situation.settlementStatus !=
                            SettlementStatus.COMPLETED)
                      ElevatedButton(
                        onPressed: () async {
                          await _completeTransaction(
                            transaction.settlementTransactionId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 18, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '완료 처리',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return const Icon(Icons.check_circle, color: Colors.green, size: 16);
      case TransactionStatus.FAILED:
        return const Icon(Icons.error, color: Colors.orange, size: 16);
      case TransactionStatus.CANCELED:
        return const Icon(Icons.cancel, color: Colors.red, size: 16);
      case TransactionStatus.PENDING:
        return const Icon(Icons.access_time, color: Colors.blue, size: 16);
      default:
        return null;
    }
  }

  Color _getStatusColor(SettlementStatus status) {
    switch (status) {
      case SettlementStatus.PENDING:
        return Colors.orange;
      case SettlementStatus.IN_PROGRESS:
        return Colors.blue;
      case SettlementStatus.COMPLETED:
        return Colors.green;
      case SettlementStatus.CANCELED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTransactionStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.PENDING:
        return Colors.blue;
      case TransactionStatus.COMPLETED:
        return Colors.green;
      case TransactionStatus.FAILED:
        return Colors.orange;
      case TransactionStatus.CANCELED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
