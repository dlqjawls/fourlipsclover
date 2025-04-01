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
  bool _isLoading = true;
  String? _error;
  MatchingDetail? _matchingDetail;

  @override
  void initState() {
    super.initState();
    _loadMatchingDetail();
  }

  Future<void> _loadMatchingDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final detail = await _matchingService.getMatchDetail(widget.matchId);
      
      setState(() {
        _matchingDetail = detail;
      });
    } catch (e) {
      setState(() {
        _error = '매칭 정보를 불러오는데 실패했습니다.';
      });
      debugPrint('매칭 상세 조회 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 상세 정보'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatchingDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatchingDetail,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_matchingDetail == null) {
      return const Center(
        child: Text('매칭 정보가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatchingDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final (statusText, statusColor) = _getStatusInfo(_matchingDetail!.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('지역', _matchingDetail!.regionName),
            _buildDetailItem('가이드', _matchingDetail!.guideNickname),
            _buildDetailItem('음식 선호', _matchingDetail!.foodPreference),
            _buildDetailItem('맛 선호', _matchingDetail!.tastePreference),
            _buildDetailItem('이동수단', _matchingDetail!.transportation),
            _buildDetailItem('시작일', _matchingDetail!.startDate),
            _buildDetailItem('종료일', _matchingDetail!.endDate),
            _buildDetailItem('요구사항', _matchingDetail!.requirements),
            _buildDetailItem('생성일', _formatDateTime(_matchingDetail!.createdAt)),
          ],
        ),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getStatusInfo(String status) {
    return switch (status) {
      'CONFIRMED' => ('매칭 수락됨', Colors.green),
      'PENDING' => ('매칭 대기중', Colors.orange),
      'REJECTED' => ('매칭 거절됨', Colors.red),
      _ => ('진행중', Colors.grey),
    };
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.year}년 ${dt.month}월 ${dt.day}일';
    } catch (e) {
      return dateTime;
    }
  }
}