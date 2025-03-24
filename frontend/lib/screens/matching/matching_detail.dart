import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/matching_detail.dart';

class MatchingDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchingDetailScreen({Key? key, required this.matchId})
    : super(key: key);

  @override
  State<MatchingDetailScreen> createState() => _MatchingDetailScreenState();
}

class _MatchingDetailScreenState extends State<MatchingDetailScreen> {
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
      // TODO: API 호출 구현
      // final response = await dio.post(
      //   '/api/matches/detail',
      //   data: {
      //     'match_id': widget.matchId,
      //   },
      // );
      // setState(() {
      //   matchingDetail = MatchingDetail.fromJson(response.data);
      // });
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (matchingDetail == null) {
      return const Scaffold(body: Center(child: Text('매칭 정보를 불러올 수 없습니다.')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '매칭 상세',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildScheduleSection(),
            const SizedBox(height: 24),
            _buildDetailsSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final color = switch (matchingDetail!.status) {
      'accepted' => Colors.green,
      'requested' => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 8),
          Text(switch (matchingDetail!.status) {
            'accepted' => '매칭이 수락되었습니다',
            'requested' => '매칭 수락 대기중입니다',
            _ => '매칭이 진행중입니다',
          }, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(matchingDetail!.local.profileImg),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                matchingDetail!.local.nickname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${matchingDetail!.city.cityName} 인증 가이드',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '여행 일정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.location_on,
                '여행지',
                '${matchingDetail!.city.regionName} ${matchingDetail!.city.cityName}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                '날짜',
                '${_formatDate(matchingDetail!.schedule.startDate)} - ${_formatDate(matchingDetail!.schedule.endDate)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.wallet,
                '예산',
                '${(matchingDetail!.details.budget / 10000).toStringAsFixed(0)}만원',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '메시지',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildMessageCard(
          matchingDetail!.user.nickname,
          matchingDetail!.details.userMessage,
          matchingDetail!.user.profileImg,
        ),
        const SizedBox(height: 8),
        if (matchingDetail!.details.localMessage.isNotEmpty)
          _buildMessageCard(
            matchingDetail!.local.nickname,
            matchingDetail!.details.localMessage,
            matchingDetail!.local.profileImg,
          ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선호사항',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              matchingDetail!.details.preferences.map((preference) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$preference',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(String name, String message, String profileImg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(profileImg),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
