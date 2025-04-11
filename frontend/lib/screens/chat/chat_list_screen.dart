import 'package:flutter/material.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/config/theme.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'chat_room_screen.dart';
import 'package:frontend/widgets/toast_bar.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_hashtag.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final AnimationController _animationController;

  // 채팅방 선택 관련 상태
  int? _selectedChatRoomId;
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatRoom> _filteredChatRooms = [];

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController.addListener(_filterChatRooms);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterChatRooms() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredChatRooms = List.from(_chatRooms);
      });
      return;
    }

    setState(() {
      _filteredChatRooms =
          _chatRooms.where((room) {
            return room.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chatRooms = await _chatService.getChatRooms();
      setState(() {
        _chatRooms = chatRooms;
        _filteredChatRooms = List.from(chatRooms);
        _isLoading = false;
      });

      // 애니메이션 실행
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = '채팅방 목록을 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침 시 애니메이션 재설정
          _animationController.reset();
          await _loadChatRooms();
        },
        color: AppColors.primary,
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title:
          _isSearchMode
              ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '채팅방 검색',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                autofocus: true,
              )
              : const Text(
                '채팅',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isSearchMode ? Icons.close : Icons.search,
            color: Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _isSearchMode = !_isSearchMode;
              if (!_isSearchMode) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    // 채팅방이 있을 때만 표시
    if (_chatRooms.isEmpty) return null;

    return FloatingActionButton(
      heroTag: 'chatFab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MatchingCreateHashtagScreen(),
          ),
        );
        ToastBar.clover('새 채팅방은 매칭을 통해 생성됩니다');
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      hoverColor: AppColors.primary.withOpacity(0.8),
      highlightElevation: 8,
      child: const Icon(Icons.chat, color: Colors.white),
      elevation: 4,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              '채팅방 목록을 불러오는 중입니다...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadChatRooms,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredChatRooms.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${_searchController.text}" 검색어를 찾을 수 없습니다',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _filteredChatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = _filteredChatRooms[index];

        // 애니메이션 적용
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index / _filteredChatRooms.length) * 0.5,
              ((index + 1) / _filteredChatRooms.length) * 0.5 + 0.5,
              curve: Curves.easeOutQuart,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animation.value)),
              child: Opacity(opacity: animation.value, child: child),
            );
          },
          child: _buildChatRoomItem(chatRoom),
        );
      },
    );
  }

  Widget _buildChatRoomItem(ChatRoom chatRoom) {
    // 임시로 가짜 데이터 생성 - 실제로는 API에서 가져와야 함
    final lastMessage = chatRoom.lastMessage ?? '새로운 채팅방이 생성되었습니다';
    final lastMessageTime =
        chatRoom.lastMessageTime ??
        DateTime.now().subtract(const Duration(minutes: 30));

    // 시간 포맷팅 로직 개선
    String formattedTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      lastMessageTime.year,
      lastMessageTime.month,
      lastMessageTime.day,
    );

    if (messageDate.isAtSameMomentAs(today)) {
      // 오늘인 경우 시간만 표시
      formattedTime = DateFormat('a h:mm', 'ko_KR').format(lastMessageTime);
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
      // 일주일 이내인 경우 요일 표시
      formattedTime = DateFormat('E', 'ko_KR').format(lastMessageTime);
    } else {
      // 그 외의 경우 날짜 표시
      formattedTime = DateFormat('yy.MM.dd', 'ko_KR').format(lastMessageTime);
    }

    // 임의의 읽지 않은 메시지 수 (실제로는 API에서 가져와야 함)
    final unreadCount = chatRoom.unreadCount ?? 0;

    final isSelected = _selectedChatRoomId == chatRoom.chatRoomId;

    return Dismissible(
      key: Key('chat_room_${chatRoom.chatRoomId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_off, color: Colors.white),
            SizedBox(height: 4),
            Text('알림 끄기', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // 실제로는 여기서 알림 설정을 토글하는 로직 구현
        ToastBar.clover('${chatRoom.name} 채팅방 알림이 꺼졌습니다');
        return false; // 항목을 삭제하지 않음
      },
      child: Material(
        color: isSelected ? AppColors.lightGray.withOpacity(0.3) : Colors.white,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedChatRoomId = chatRoom.chatRoomId;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ChatRoomScreen(
                      chatRoomId: chatRoom.chatRoomId,
                      groupId: chatRoom.groupId,
                    ),
              ),
            ).then((_) {
              _loadChatRooms();
              setState(() {
                _selectedChatRoomId = null;
              });
            });
          },
          onLongPress: () {
            _showChatRoomOptions(chatRoom);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                // 채팅방 프로필 이미지
                _buildChatRoomAvatar(chatRoom),
                const SizedBox(width: 16),

                // 채팅방 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chatRoom.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  unreadCount > 0
                                      ? AppColors.primary
                                      : Colors.grey.shade500,
                              fontWeight:
                                  unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // 참여자 수 배지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${chatRoom.participantNum}명',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    unreadCount > 0
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                fontWeight:
                                    unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatRoomAvatar(ChatRoom chatRoom) {
    final bool hasGroupImage =
        chatRoom.thumbnailUrl != null && chatRoom.thumbnailUrl!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                hasGroupImage
                    ? null
                    : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.4),
                      ],
                    ),
            image:
                hasGroupImage
                    ? DecorationImage(
                      image: NetworkImage(chatRoom.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              !hasGroupImage
                  ? Center(
                    child: Icon(
                      chatRoom.participantNum > 2 ? Icons.group : Icons.person,
                      size: 28,
                      color: Colors.white,
                    ),
                  )
                  : null,
        ),
        if (chatRoom.isActive ?? true)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showChatRoomOptions(ChatRoom chatRoom) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_off),
                  title: const Text('알림 끄기'),
                  onTap: () {
                    Navigator.pop(context);
                    ToastBar.clover('${chatRoom.name} 채팅방 알림이 꺼졌습니다');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('채팅방 보관'),
                  onTap: () {
                    Navigator.pop(context);
                    ToastBar.clover('${chatRoom.name} 채팅방이 보관되었습니다');
                  },
                ),
                if (chatRoom.isAdmin ?? false)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      '채팅방 나가기',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showLeaveConfirmationDialog(chatRoom);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _showLeaveConfirmationDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('채팅방 나가기'),
            content: Text(
              '정말 "${chatRoom.name}" 채팅방을 나가시겠습니까?\n채팅 내용이 모두 삭제됩니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 채팅방 나가기 API 호출
                  ToastBar.clover('${chatRoom.name} 채팅방을 나갔습니다');
                  _loadChatRooms();
                },
                child: const Text('나가기', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 애니메이션되는 일러스트레이션
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '채팅방이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '새로운 매칭이 생성되면\n채팅방이 자동으로 생성됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchingCreateHashtagScreen(),
                ),
              );
              ToastBar.clover('매칭 화면으로 이동합니다');
            },
            icon: const Icon(Icons.people_alt, color: Colors.white, size: 24),
            label: const Text('매칭하러 가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
