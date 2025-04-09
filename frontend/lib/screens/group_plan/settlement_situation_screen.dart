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

class SettlementSituationScreen extends StatefulWidget {
  final int planId;
  final String planTitle;

  const SettlementSituationScreen({
    Key? key,
    required this.planId,
    required this.planTitle,
  }) : super(key: key);

  @override
  State<SettlementSituationScreen> createState() => _SettlementSituationScreenState();
}

class _SettlementSituationScreenState extends State<SettlementSituationScreen> {
  final currencyFormatter = NumberFormat('#,###', 'ko_KR');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<SettlementProvider>(context, listen: false)
          .fetchSettlementSituation(widget.planId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정산 현황을 불러오는 데 실패했습니다: $e')),
        );
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
      final result = await Provider.of<SettlementProvider>(context, listen: false)
          .completeTransaction(widget.planId, transactionId);

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정산 완료 처리되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정산 완료 처리에 실패했습니다: $e')),
        );
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('정산 현황'),
          backgroundColor: AppColors.primary,
        ),
        body: RefreshIndicator(
          onRefresh: _fetchData,
          child: Consumer<SettlementProvider>(
            builder: (context, settlementProvider, _) {
              final situations = settlementProvider
                  .getSettlementSituationForPlan(widget.planId);

              if (situations == null || situations.isEmpty) {
                return const Center(
                  child: Text('정산 현황이 없습니다. 아래로 당겨서 새로고침 하세요.'),
                );
              }

              // 첫 번째 상황 정보 사용 (목록에 여러 개가 있을 수 있음)
              final situation = situations.first;

              return Column(
                children: [
                  _buildHeader(situation),
                  Expanded(
                    child: _buildTransactionList(situation),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SettlementSituationResponse situation) {
    final statusText = Provider.of<SettlementProvider>(context, listen: false)
        .getSettlementStatusText(situation.settlementStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.verylightGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.planTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('총무: ${situation.treasurerName}'),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(situation.settlementStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '기간: ${DateFormat('yyyy.MM.dd').format(situation.startDate)} - ${DateFormat('yyyy.MM.dd').format(situation.endDate)}',
            style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
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
      final getStatusPriority = (TransactionStatus status) {
        switch (status) {
          case TransactionStatus.PENDING: return 0;
          case TransactionStatus.FAILED: return 1;
          case TransactionStatus.COMPLETED: return 2;
          case TransactionStatus.CANCELED: return 3;
          default: return 4;
        }
      };
      
      return getStatusPriority(a.transactionStatus) 
          .compareTo(getStatusPriority(b.transactionStatus));
    });

    if (transactions.isEmpty) {
      return const Center(
        child: Text('정산 거래 내역이 없습니다.'),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isPending = transaction.transactionStatus == TransactionStatus.PENDING;
        final statusText = Provider.of<SettlementProvider>(context, listen: false)
            .getTransactionStatusText(transaction.transactionStatus);
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            children: [
              Text(
                transaction.payer.nickname ?? transaction.payer.name ?? '사용자',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_right_alt),
              Text(
                transaction.payee.nickname ?? transaction.payee.name ?? '총무',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currencyFormatter.format(transaction.cost)}원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '상태: $statusText',
                style: TextStyle(
                  color: _getTransactionStatusColor(transaction.transactionStatus),
                ),
              ),
              if (transaction.createdAt != null)
                Text(
                  '요청일: ${DateFormat('yyyy.MM.dd').format(transaction.createdAt!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              if (transaction.sentAt != null)
                Text(
                  '완료일: ${DateFormat('yyyy.MM.dd').format(transaction.sentAt!)}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          trailing: isPending && situation.settlementStatus != SettlementStatus.COMPLETED
              ? ElevatedButton(
                  onPressed: () => _completeTransaction(transaction.settlementTransactionId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('완료 처리'),
                )
              : _getStatusIcon(transaction.transactionStatus),
        );
      },
    );
  }

  Widget? _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TransactionStatus.FAILED:
        return const Icon(Icons.error, color: Colors.orange);
      case TransactionStatus.CANCELED:
        return const Icon(Icons.cancel, color: Colors.red);
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