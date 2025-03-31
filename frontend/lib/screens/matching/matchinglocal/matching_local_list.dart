import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/services/matching/matching_service.dart';
import 'matching_local_resist.dart';

class MatchingLocalListScreen extends StatefulWidget {
  const MatchingLocalListScreen({Key? key}) : super(key: key);

  @override
  State<MatchingLocalListScreen> createState() =>
      _MatchingLocalListScreenState();
}

class _MatchingLocalListScreenState extends State<MatchingLocalListScreen> {
  final MatchingService _matchingService = MatchingService();
  List<dynamic> acceptedRequests = [];
  List<dynamic> pendingRequests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => isLoading = true);
    try {
      final matches = await _matchingService.getGuideMatchRequests();
      setState(() {
        acceptedRequests =
            matches.where((m) => m.status == 'CONFIRMED').toList();
        pendingRequests = matches.where((m) => m.status == 'PENDING').toList();
      });
    } catch (e) {
      debugPrint('매칭 목록 로드 실패: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('가이드 기획서'),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadMatches,
                child: Column(
                  children: [
                    _buildSectionHeader('접수 목록', acceptedRequests.length),
                    Expanded(
                      flex: 1,
                      child:
                          acceptedRequests.isEmpty
                              ? _buildEmptyState('접수된 요청이 없습니다')
                              : _buildAcceptedList(),
                    ),
                    _buildSectionHeader('나에게 온 신청목록', pendingRequests.length),
                    Expanded(
                      flex: 2,
                      child:
                          pendingRequests.isEmpty
                              ? _buildEmptyState('새로운 신청이 없습니다')
                              : _buildPendingList(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildAcceptedList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: acceptedRequests.length,
            itemBuilder:
                (context, index) => _buildAcceptedCard(acceptedRequests[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pendingRequests.length,
      itemBuilder:
          (context, index) => _buildPendingCard(pendingRequests[index]),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedCard(dynamic match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.regionName ?? '지역명',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '음식 선호: ${match.foodPreference}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            Text(
              '맛 선호: ${match.tastePreference}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            Text(
              '이동수단: ${match.transportation}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            Text(
              '시작: ${match.startDate}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            Text(
              '종료: ${match.endDate}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            Text(
              '요구사항: ${match.requirements}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 기획서 확인
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      elevation: 0,
                    ),
                    child: const Text('기획서 확인'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 채팅방 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: const Text('대화하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(dynamic match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.regionName ?? '지역명',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('음식 선호: ${match.foodPreference}'),
                  Text('맛 선호: ${match.tastePreference}'),
                  Text('이동수단: ${match.transportation}'),
                  Text('시작: ${match.startDate}'),
                  Text('종료: ${match.endDate}'),
                  Text('요구사항: ${match.requirements}'),
                ],
              ),
            ),
            Column(
              children: [
                _buildActionButton(
                  onPressed: () async {
                    // TODO: 거절 처리
                  },
                  icon: Icons.close,
                  color: AppColors.red,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  onPressed: () async {
                    // TODO: 수락 처리
                  },
                  icon: Icons.check,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppColors.mediumGray)),
    );
  }
}
