import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_hashtag.dart';
import 'package:frontend/screens/matching/matching_detail.dart';
import 'package:frontend/screens/matching/matchinglocal/matching_local_list.dart';
import 'package:frontend/providers/matching_provider.dart';
import 'package:frontend/screens/matching/widgets/matching_banner.dart';
import 'package:frontend/screens/matching/widgets/matching_empty_state.dart';
import 'package:frontend/models/matching/matching_main_model.dart';
import 'package:frontend/widgets/loading_overlay.dart';
import 'package:frontend/screens/chat/chat_room_screen.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/widgets/toast_bar.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      await context.read<MatchingProvider>().checkUserRole();
      await context.read<MatchingProvider>().fetchMatches();
    } catch (e) {
      if (mounted) {
        ToastBar.clover('데이터 로드 중 오류가 발생했습니다');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이전 로직 제거
  }

  void _navigateToCreateMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchingCreateHashtagScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final matchingProvider = context.watch<MatchingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          matchingProvider.isGuide ? '매칭 신청 목록' : '나의 매칭 목록',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: matchingProvider.isLoading,
        overlayColor: Colors.white.withOpacity(0.7),
        minDisplayTime: const Duration(milliseconds: 1200),
        child: Column(
          children: [
            FutureBuilder<Map<String, int>>(
              future: matchingProvider.getMatchingCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final counts =
                    snapshot.data ?? {'confirmedCount': 0, 'pendingCount': 0};
                return MatchingBanner(
                  confirmedCount: counts['confirmedCount'] ?? 0,
                  pendingCount: counts['pendingCount'] ?? 0,
                );
              },
            ),
            Expanded(
              child:
                  matchingProvider.matches.isEmpty
                      ? MatchingEmptyState(
                        onCreateMatch: _navigateToCreateMatch,
                      )
                      : _buildMatchList(matchingProvider.matches),
            ),
          ],
        ),
      ),
      floatingActionButton:
          matchingProvider.matches.isNotEmpty
              ? FloatingActionButton(
                onPressed: _navigateToCreateMatch,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildMatchList(List<dynamic> matches) {
    return RefreshIndicator(
      onRefresh: () => context.read<MatchingProvider>().fetchMatches(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return _buildMatchItem(match);
        },
      ),
    );
  }

  Widget _buildMatchItem(dynamic match) {
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
                    context.read<MatchingProvider>().isGuide
                        ? '신청자'
                        : match.guideNickname,
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
                  Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    match.regionName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (match is MatchRequest) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.wallet, size: 16, color: AppColors.primary),
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
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary,
                  ),
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

  void _navigateToDetail(dynamic match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchingDetailScreen(matchId: match.matchId),
      ),
    );
  }

  void _navigateToChat(dynamic match) async {
    try {
      // 채팅방 이동 전에 토스트 메시지 표시
      ToastBar.clover('채팅방으로 이동합니다');

      final chatService = ChatService();
      final chatRooms = await chatService.getChatRooms();

      // 매칭 ID와 일치하는 채팅방 찾기
      final matchingChatRoom = chatRooms.firstWhere(
        (room) => room.matchId == match.matchId,
        orElse:
            () => ChatRoom(
              chatRoomId: match.matchId,
              groupId: match.matchId,
              name: match.guideNickname ?? '채팅방',
              participantNum: 2,
              matchId: match.matchId,
            ),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatRoomScreen(
                  chatRoomId: matchingChatRoom.chatRoomId,
                  groupId: matchingChatRoom.groupId,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 에러 발생 시 토스트 메시지로 표시
        ToastBar.clover('채팅방 이동 중 오류가 발생했습니다');
      }
    }
  }
}
