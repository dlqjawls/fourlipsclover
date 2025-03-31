import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/matching/matching_detail.dart';
import 'package:frontend/services/matching/matching_service.dart';

class MatchingDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchingDetailScreen({Key? key, required this.matchId})
    : super(key: key);

  @override
  State<MatchingDetailScreen> createState() => _MatchingDetailScreenState();
}

class _MatchingDetailScreenState extends State<MatchingDetailScreen> {
  final MatchingService _matchingService = MatchingService();
  bool isLoading = true;
  MatchingDetail? matchingDetail;

  @override
  void initState() {
    super.initState();
    _fetchMatchingDetail();
  }

  Future<void> _fetchMatchingDetail() async {
    setState(() => isLoading = true);
    try {
      final detail = await _matchingService.getMatchDetail(widget.matchId);
      setState(() {
        matchingDetail = detail;
      });
    } catch (e) {
      debugPrint('매칭 상세 조회 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('매칭 정보를 불러오는데 실패했습니다.')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매칭 상세'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : matchingDetail == null
              ? const Center(child: Text('매칭 정보를 불러올 수 없습니다.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildDetailItem('지역', matchingDetail!.regionName),
                    _buildDetailItem('가이드', matchingDetail!.guideNickname),
                    _buildDetailItem('음식 선호', matchingDetail!.foodPreference),
                    _buildDetailItem('맛 선호', matchingDetail!.tastePreference),
                    _buildDetailItem('이동수단', matchingDetail!.transportation),
                    _buildDetailItem('시작일', matchingDetail!.startDate),
                    _buildDetailItem('종료일', matchingDetail!.endDate),
                    _buildDetailItem('요구사항', matchingDetail!.requirements),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusCard() {
    final statusText = switch (matchingDetail!.status) {
      'CONFIRMED' => '수락됨',
      'PENDING' => '대기중',
      'REJECTED' => '거절됨',
      _ => '진행중',
    };

    final statusColor = switch (matchingDetail!.status) {
      'CONFIRMED' => Colors.green,
      'PENDING' => Colors.orange,
      'REJECTED' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
