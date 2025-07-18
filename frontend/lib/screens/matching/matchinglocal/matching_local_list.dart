import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/services/matching/matching_service.dart';
import 'package:frontend/models/matching/matching_main_model.dart'; // 추가
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/models/chat_model.dart';
import 'matching_local_resist.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/screens/chat/chat_room_screen.dart';
import 'package:frontend/widgets/loading_overlay.dart';
import 'package:frontend/widgets/toast_bar.dart'; // ToastBar import 추가

class MatchingLocalListScreen extends StatefulWidget {
  const MatchingLocalListScreen({Key? key})
    : super(key: key); // required 파라미터 제거

  @override
  State<MatchingLocalListScreen> createState() =>
      _MatchingLocalListScreenState();
}

class _MatchingLocalListScreenState extends State<MatchingLocalListScreen>
    with SingleTickerProviderStateMixin {
  final MatchingService _matchingService = MatchingService();
  List<dynamic> acceptedRequests = [];
  List<dynamic> pendingRequests = [];
  bool isLoading = false;
  late TabController _tabController;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatches();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => false,
      calendarFormat: CalendarFormat.month,
      locale: 'ko_KR',
      daysOfWeekHeight: 24,
      rowHeight: 45,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Anemone_air',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 0,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        weekendStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          // 현재 선택된 매칭의 날짜 범위에 속하는지 확인
          for (var match in [...acceptedRequests, ...pendingRequests]) {
            DateTime startDate = DateTime.parse(match.startDate);
            DateTime endDate = DateTime.parse(match.endDate);

            if (isSameDay(day, startDate) ||
                isSameDay(day, endDate) ||
                (day.isAfter(startDate) && day.isBefore(endDate))) {
              bool isStart = isSameDay(day, startDate);
              bool isEnd = isSameDay(day, endDate);

              return _buildRangeCell(
                day,
                AppColors.primary.withOpacity(0.2),
                AppColors.primary,
                isStart,
                isEnd,
              );
            }
          }
          return Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeCell(
    DateTime day,
    Color fillColor,
    Color borderColor,
    bool isStart,
    bool isEnd,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: fillColor,
        border: Border(
          left:
              isStart
                  ? BorderSide(color: borderColor, width: 1.5)
                  : BorderSide.none,
          top: BorderSide(color: borderColor, width: 1.5),
          right:
              isEnd
                  ? BorderSide(color: borderColor, width: 1.5)
                  : BorderSide.none,
          bottom: BorderSide(color: borderColor, width: 1.5),
        ),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isStart ? 100 : 0),
          right: Radius.circular(isEnd ? 100 : 0),
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _loadMatches() async {
    setState(() => isLoading = true);

    // 접수된 매칭 로드
    try {
      final confirmedMatches = await _matchingService.getConfirmedMatches();
      setState(() {
        acceptedRequests = confirmedMatches;
        debugPrint('확정된 매칭 수: ${acceptedRequests.length}');
      });
    } catch (e) {
      debugPrint('확정된 매칭 로드 중 오류: $e');
      setState(() => acceptedRequests = []);
    }

    // 대기중인 매칭 로드
    try {
      final pendingMatches = await _matchingService.getGuideMatchRequests();
      setState(() {
        pendingRequests =
            pendingMatches.where((m) => m.status == 'PENDING').toList();
        debugPrint('대기중인 매칭 수: ${pendingRequests.length}');
      });
    } catch (e) {
      debugPrint('대기중인 매칭 로드 중 오류: $e');
      setState(() => pendingRequests = []);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '여행 지역 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mediumGray,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('접수 목록'),
                  const SizedBox(width: 8),
                  if (acceptedRequests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        acceptedRequests.length.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('신청 목록'),
                  const SizedBox(width: 8),
                  if (pendingRequests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pendingRequests.length.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        overlayColor: Colors.white.withOpacity(0.7),
        minDisplayTime: const Duration(milliseconds: 1200),
        child: RefreshIndicator(
          onRefresh: _loadMatches,
          child: TabBarView(
            controller: _tabController,
            children: [
              // 접수 목록 탭
              Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildCalendar(),
                    ),
                  ),
                  Expanded(
                    child:
                        acceptedRequests.isEmpty
                            ? _buildEmptyState('접수된 요청이 없습니다')
                            : _buildAcceptedList(),
                  ),
                ],
              ),
              // 신청 목록 탭
              Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildCalendar(),
                    ),
                  ),
                  Expanded(
                    child:
                        pendingRequests.isEmpty
                            ? _buildEmptyState('새로운 신청이 없습니다')
                            : _buildPendingList(),
                  ),
                ],
              ),
            ],
          ),
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
    return ExpansionTile(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.regionName ?? '지역명',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${match.startDate} ~ ${match.endDate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(Icons.restaurant, '음식 선호', match.foodPreference),
              _buildDetailItem(Icons.thumb_up, '맛 선호', match.tastePreference),
              _buildDetailItem(
                Icons.directions_car,
                '이동수단',
                match.transportation,
              ),
              _buildDetailItem(Icons.note, '요구사항', match.requirements),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 기획서 확인
                      },
                      icon: const Icon(Icons.description, size: 18),
                      label: const Text('기획서 확인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final chatService = ChatService();
                          final chatRooms = await chatService.getChatRooms();

                          // 매칭 ID와 일치하는 채팅방 찾기
                          final matchingChatRoom = chatRooms.firstWhere(
                            (room) => room.matchId == match.matchId,
                            orElse:
                                () => ChatRoom(
                                  chatRoomId: match.matchId,
                                  groupId: match.matchId,
                                  name: match.regionName ?? '채팅방',
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
                            ToastBar.clover('채팅방 이동 중 오류가 발생했습니다');
                          }
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('대화하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCard(dynamic match) {
    return ExpansionTile(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.regionName ?? '지역명',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${match.startDate} ~ ${match.endDate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(Icons.restaurant, '음식 선호', match.foodPreference),
              _buildDetailItem(Icons.thumb_up, '맛 선호', match.tastePreference),
              _buildDetailItem(
                Icons.directions_car,
                '이동수단',
                match.transportation,
              ),
              _buildDetailItem(Icons.note, '요구사항', match.requirements),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    onPressed: () async {
                      try {
                        await _matchingService.rejectMatch(match.matchId);
                        if (!mounted) return;

                        // 토스트 메시지 표시
                        ToastBar.clover('매칭을 거절했습니다');

                        // 매칭 목록 새로고침
                        setState(() {
                          _loadMatches();
                        });
                      } catch (e) {
                        if (!mounted) return;
                        ToastBar.clover('매칭 거절 실패');
                      }
                    },
                    icon: Icons.close,
                    color: AppColors.red,
                    label: '거절하기',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    onPressed: () async {
                      try {
                        await _matchingService.confirmMatch(match.matchId);
                        await _loadMatches();
                        if (mounted) {
                          // 토스트 메시지 표시
                          ToastBar.clover('매칭이 수락되었습니다');
                        }
                      } catch (e) {
                        if (mounted) {
                          // 토스트 메시지 표시
                          ToastBar.clover('매칭 수락 실패');
                        }
                      }
                    },
                    icon: Icons.check,
                    color: AppColors.primary,
                    label: '수락하기',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mediumGray),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // _buildEmptyState 메서드 추가
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.mediumGray, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
