import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/theme.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;

  const ChatRoomScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatRoomDetail? _chatRoom;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentUserId = 0; // 현재 로그인한 사용자 ID
  Timer? _pollingTimer;
  DateTime _lastMessageTime = DateTime.now();
  bool _showNewMessageButton = false; // 새 메시지 버튼 표시 여부
  int _lastMessageCount = 0; // 마지막 메시지 개수
  bool _shouldAutoScroll = true; // 자동 스크롤 여부를 결정하는 플래그
  bool _showNewMessageBanner = false; // 새 메시지 알림 배너 표시 여부
  int _newMessageCount = 0; // 새로 도착한 메시지 개수

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadChatRoom();
    _startPolling();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final scrollPercentage = currentScroll / maxScroll;

      setState(() {
        _showNewMessageButton = scrollPercentage < 0.95;
        // 사용자가 스크롤을 수동으로 조작하면 자동 스크롤 비활성화
        if (_scrollController.position.isScrollingNotifier.value) {
          _shouldAutoScroll = false;
        }
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        setState(() {
          _currentUserId = int.parse(userId);
        });
      }
    } catch (e) {
      debugPrint('사용자 정보 로드 중 오류: $e');
    }
  }

  void _startPolling() {
    // 10초마다 새 메시지 확인
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNewMessages();
    });
  }

  Future<void> _checkNewMessages() async {
    if (_chatRoom == null) return;

    try {
      final messages = await _chatService.getNewMessages(
        widget.chatRoomId,
        _lastMessageTime,
      );

      if (messages.isNotEmpty) {
        setState(() {
          final existingMessageIds =
              _chatRoom!.messages.map((m) => m.messageId).toSet();
          final newMessages =
              messages
                  .where(
                    (message) =>
                        !existingMessageIds.contains(message.messageId),
                  )
                  .toList();

          if (newMessages.isNotEmpty) {
            _chatRoom!.messages.addAll(newMessages);
            _lastMessageTime = newMessages.last.createdAt;

            // 자동 스크롤이 비활성화되어 있을 때만 새 메시지 알림 표시
            if (!_shouldAutoScroll) {
              _showNewMessageBanner = true;
              _newMessageCount += newMessages.length;
            }
          }
        });

        if (_shouldAutoScroll) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('새 메시지 확인 중 오류: $e');
    }
  }

  void _hideNewMessageBanner() {
    setState(() {
      _showNewMessageBanner = false;
      _newMessageCount = 0;
    });
  }

  Widget _buildNewMessageBanner() {
    if (!_showNewMessageBanner) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _scrollToBottom();
          _hideNewMessageBanner();
          setState(() {
            _shouldAutoScroll = true;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_downward, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              '새 메시지 $_newMessageCount개',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadChatRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 모든 메시지 가져오기 (페이지네이션 없이)
      final chatRoomDetail = await _chatService.getChatRoom(
        widget.chatRoomId,
        0, // 시작 인덱스
        200, // 모든 메시지 가져오기
      );

      setState(() {
        _chatRoom = chatRoomDetail;
        _isLoading = false;

        // 채팅 메시지가 있으면 마지막 메시지 시간 저장
        if (_chatRoom!.messages.isNotEmpty) {
          _lastMessageTime = _chatRoom!.messages.last.createdAt;
        }
      });

      // 메시지 로드 후 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '채팅방 정보를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 약간의 딜레이를 주어 UI가 완전히 업데이트된 후 스크롤되도록 함
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentUserId == 0) return;

    // 메시지 입력창 비우기
    _messageController.clear();

    try {
      final sentMessage = await _chatService.sendMessage(
        widget.chatRoomId,
        _currentUserId,
        message,
      );

      setState(() {
        // 메시지 목록에 추가 (맨 앞에 추가)
        _chatRoom!.messages.insert(0, sentMessage);
        _lastMessageTime = sentMessage.createdAt;
        // 메시지를 보낼 때는 항상 자동 스크롤 활성화
        _shouldAutoScroll = true;
      });

      // 메시지 전송 후 즉시 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('메시지 전송 중 오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 키보드 포커스 해제
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면이 밀려 올라가도록 설정
        appBar: AppBar(
          title:
              _chatRoom != null
                  ? Text(
                    _chatRoom!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                  : const Text(
                    '채팅방',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          centerTitle: true,
          actions: [
            if (_chatRoom != null)
              IconButton(
                icon: const Icon(Icons.people),
                onPressed: () {
                  _showMembersList();
                },
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChatRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_chatRoom == null) {
      return const Center(child: Text('채팅방 정보를 불러올 수 없습니다.'));
    }

    return Column(
      children: [
        // 채팅 메시지 목록
        Expanded(
          child:
              _chatRoom!.messages.isEmpty
                  ? _buildEmptyMessages()
                  : _buildMessageList(),
        ),

        // 메시지 입력창
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '${_chatRoom!.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_chatRoom!.members.length}명이 참여중인 채팅방입니다.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            '첫 메시지를 보내보세요!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _chatRoom!.messages.toList();
    final reversedMessages = List<ChatMessage>.from(messages.reversed);

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          ),
          itemCount: reversedMessages.length,
          itemBuilder: (context, index) {
            final message = reversedMessages[index];
            final isMine = message.memberId == _currentUserId;

            final bool showDate =
                index == 0 ||
                !_isSameDay(
                  reversedMessages[index].createdAt,
                  reversedMessages[index - 1].createdAt,
                );

            return Column(
              children: [
                if (showDate) _buildDateSeparator(message.createdAt),
                _buildMessageItem(message, isMine),
              ],
            );
          },
        ),
        if (_showNewMessageButton)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () {
                _scrollToBottom();
                setState(() {
                  _showNewMessageButton = false;
                });
              },
              child: const Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ),
        Positioned(top: 8, left: 0, right: 0, child: _buildNewMessageBanner()),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    final formattedDate = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isMine) {
    final formattedTime = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 발신자 정보 (내 메시지가 아닐 경우)
          if (!isMine) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage:
                  message.profileUrl != null
                      ? NetworkImage(message.profileUrl!)
                      : null,
              child:
                  message.profileUrl == null
                      ? Text(message.nickname.substring(0, 1))
                      : null,
            ),
            const SizedBox(width: 8),
          ],

          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // 발신자 닉네임 (내 메시지가 아닐 경우)
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    message.nickname,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // 메시지 내용과 시간
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 시간 (내 메시지일 경우 왼쪽에 표시)
                  if (isMine)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // 메시지 버블
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMine ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      message.messageContent,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMine ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  // 시간 (상대방 메시지일 경우 오른쪽에 표시)
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 메시지 입력 필드
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),

          // 전송 버튼
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '참여자 목록 (${_chatRoom!.members.length}명)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _chatRoom!.members.length,
                    itemBuilder: (context, index) {
                      final member = _chatRoom!.members[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              member.profileUrl != null
                                  ? NetworkImage(member.profileUrl!)
                                  : null,
                          child:
                              member.profileUrl == null
                                  ? Text(member.memberNickname.substring(0, 1))
                                  : null,
                        ),
                        title: Text(
                          member.memberNickname,
                          style: TextStyle(
                            fontWeight:
                                member.memberId == _currentUserId
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('yyyy년 M월 d일', 'ko_KR').format(member.joinedAt)} 참여',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing:
                            member.memberId == _currentUserId
                                ? const Chip(
                                  label: Text(
                                    '나',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  labelStyle: TextStyle(color: Colors.white),
                                )
                                : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
