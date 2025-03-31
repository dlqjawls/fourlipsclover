import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_hashtag.dart';
import 'package:frontend/screens/matching/matching_detail.dart';
import 'package:frontend/screens/matching/matchinglocal/matching_local_list.dart';
import 'package:frontend/services/matching/matching_service.dart';
import 'package:frontend/models/matching/matching_main_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with AutomaticKeepAliveClientMixin {
  final MatchingService _matchingService = MatchingService();
  List<dynamic> matches = [];
  bool isLoading = false;
  bool isGuide = true;
  int pendingMatchCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole');
      setState(() {
        isGuide = userRole == 'GUIDE';
      });
      _fetchMatches();
    } catch (e) {
      debugPrint('사용자 역할 확인 오류: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isFromNavBar = ModalRoute.of(context)?.settings.name == null;
    if (isFromNavBar) {
      _fetchMatches();
    }
  }

  Future<void> _fetchMatches() async {
    setState(() => isLoading = true);
    try {
      if (isGuide) {
        final guideMatches = await _matchingService.getGuideMatchRequests();
        setState(() {
          matches = guideMatches;
          pendingMatchCount = guideMatches
              .where((match) => match.status == 'PENDING')
              .length;
        });
      } else {
        final applicantMatches = await _matchingService.getApplicantMatches();
        setState(() {
          matches = applicantMatches;
          pendingMatchCount = applicantMatches
              .where((match) => match.status == 'PENDING')
              .length;
        });
      }
    } catch (e) {
      debugPrint('매칭 목록 조회 오류: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isGuide ? '매칭 신청 목록' : '나의 매칭 목록',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isGuide && pendingMatchCount > 0) _buildBanner(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : matches.isEmpty
                    ? _buildEmptyState()
                    : _buildMatchList(),
          ),
        ],
      ),
      floatingActionButton: matches.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateMatch(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MatchingLocalListScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 60, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '미확인 매칭 ${pendingMatchCount}건',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '확인하러 가기',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '아직 매칭 내역이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToCreateMatch(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '새로운 매칭 만들기',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList() {
    return RefreshIndicator(
      onRefresh: _fetchMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(dynamic match) {
    final String statusText = switch (match.status) {
      'CONFIRMED' => '수락됨',
      'PENDING' => '대기중',
      'REJECTED' => '거절됨',
      _ => '진행중',
    };

    final Color statusColor = switch (match.status) {
      'CONFIRMED' => Colors.green,
      'PENDING' => Colors.orange,
      'REJECTED' => Colors.red,
      _ => Colors.grey,
    };

    return GestureDetector(
      onTap: () => _navigateToDetail(match),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isGuide ? '신청자' : match.guideNickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    match.regionName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (match is MatchRequest) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.wallet, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${match.price}원',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${match.startDate} - ${match.endDate}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCreateMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchingCreateHashtagScreen(),
      ),
    );
  }

  void _navigateToDetail(dynamic match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchingDetailScreen(
          matchId: match is MatchRequest ? match.matchId : 0,
        ),
      ),
    );
  }
}