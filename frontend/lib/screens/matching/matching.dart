import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_hashtag.dart';
import 'package:frontend/screens/matching/matching_detail.dart';
import 'package:frontend/screens/matching/matchinglocal/matching_local_list.dart';
import 'package:frontend/screens/matching/matchingchat/matching_chat.dart';
import 'package:frontend/services/matching/matching_service.dart';
import 'package:frontend/models/matching/matching_main_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/matching/matchinglocal/matching_local_resist.dart';

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

  void refreshBanner() {
    setState(() {
      // FutureBuilder가 새로운 future를 시작하도록 강제
    });
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
      // 에러가 발생해도 매칭 목록을 가져오도록 함
      _fetchMatches();
      // 나중에 유저 정보에  현지인 인증 정보 추가되면 이 부분 수정 필요
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
          pendingMatchCount =
              guideMatches.where((match) => match.status == 'PENDING').length;
        });
      } else {
        final applicantMatches = await _matchingService.getApplicantMatches();
        setState(() {
          matches = applicantMatches;
          pendingMatchCount =
              applicantMatches
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
        scrolledUnderElevation: 0,
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
          _buildBanner(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : matches.isEmpty
                    ? _buildEmptyState()
                    : _buildMatchList(),
          ),
        ],
      ),
      floatingActionButton:
          matches.isNotEmpty
              ? FloatingActionButton(
                onPressed: () => _navigateToCreateMatch(),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildBanner() {
    return FutureBuilder<Map<String, int>>(
      future: _matchingService.getMatchingCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 에러가 있더라도 데이터가 있으면 표시
        final counts =
            snapshot.data ?? {'confirmedCount': 0, 'pendingCount': 0};
        final confirmedCount = counts['confirmedCount'] ?? 0;
        final pendingCount = counts['pendingCount'] ?? 0;

        // confirmedCount가 0이 아니면 배너 표시
        if (confirmedCount == 0) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchingLocalListScreen(),
              ),
            ).then((_) {
              setState(() {});
            });
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
                      if (confirmedCount > 0)
                        Text(
                          '진행중인 매칭 ${confirmedCount}건',
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
      },
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _fetchMatches,
      child: ListView(
        // SingleChildScrollView 대신 ListView 사용
        physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 설정
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7, // 충분한 스크롤 영역 확보
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 매칭 내역이 없습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
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
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
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
                  if (match.status == 'CONFIRMED')
                    TextButton.icon(
                      onPressed: () => _navigateToChat(match),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('채팅하기'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
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
        builder: (context) => MatchingDetailScreen(matchId: match.matchId),
      ),
    );
  }

  void _navigateToChat(dynamic match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MatchingChatScreen(groupId: match.matchId.toString()),
      ),
    );
  }
}
