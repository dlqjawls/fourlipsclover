import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/services/matching/chat_service.dart';
import 'dart:async';

class ChatMessage {
  final String message;
  final bool isSentByMe;
  final String time;
  final String? imageUrl;
  final String userName;
  final String userIcon;

  ChatMessage({
    required this.message,
    required this.isSentByMe,
    required this.time,
    this.imageUrl,
    required this.userName,
    required this.userIcon,
  });
}

class MatchingChatScreen extends StatefulWidget {
  final String groupId;

  const MatchingChatScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _MatchingChatScreenState createState() => _MatchingChatScreenState();
}

class _MatchingChatScreenState extends State<MatchingChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  Timer? _pollingTimer;
  bool _isPolling = false;
  DateTime? _lastMessageTime;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _currentUserId = await _chatService.getCurrentUserId();
    await _loadInitialMessages();
    _startPolling();
  }

  Future<void> _loadInitialMessages() async {
    try {
      final response = await _chatService.getChatHistory(
        widget.groupId,
        limit: 20,
      );

      setState(() {
        _messages.addAll(
          response.map(
            (data) => ChatMessage(
              message: data['content'],
              isSentByMe: data['senderId'] == _currentUserId,
              time: data['timestamp'],
              userName: data['userName'],
              userIcon: data['userIcon'],
              imageUrl: data['imageUrl'],
            ),
          ),
        );

        if (_messages.isNotEmpty) {
          _lastMessageTime = DateTime.parse(_messages.last.time);
        }
      });
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
    }
  }

  void _startPolling() {
    _isPolling = true;
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!_isPolling) return;

      try {
        final newMessages = await _chatService.pollNewMessages(
          widget.groupId,
          lastMessageTime: _lastMessageTime,
        );

        if (newMessages.isNotEmpty) {
          setState(() {
            _messages.addAll(
              newMessages.map(
                (data) => ChatMessage(
                  message: data['content'],
                  isSentByMe: data['senderId'] == _currentUserId,
                  time: data['timestamp'],
                  userName: data['userName'],
                  userIcon: data['userIcon'],
                  imageUrl: data['imageUrl'],
                ),
              ),
            );

            _lastMessageTime = DateTime.parse(newMessages.last['timestamp']);
          });
        }
      } catch (e) {
        debugPrint('Polling error: $e');
        Future.delayed(Duration(seconds: 5), () {
          if (mounted) _startPolling();
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final message = {
        'groupId': widget.groupId,
        'content': _messageController.text,
        'senderId': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _chatService.sendMessage(message);

      setState(() {
        _messages.add(
          ChatMessage(
            message: _messageController.text,
            isSentByMe: true,
            time: DateTime.now().toIso8601String(),
            userName: '나',
            userIcon: 'assets/default_profile.png',
          ),
        );
      });

      _messageController.clear();
    } catch (e) {
      debugPrint('Failed to send message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('메시지 전송에 실패했습니다. 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/default_profile.png'),
                radius: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '매칭 채팅방',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '2명 참여중',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.darkGray),
            onPressed: () {
              // 채팅방 설정 메뉴
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isSentByMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSentByMe)
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(message.userIcon),
                  radius: 16,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isSentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (!message.isSentByMe)
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Text(
                      message.userName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color:
                        message.isSentByMe
                            ? AppColors.primary
                            : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(message.isSentByMe ? 16 : 4),
                      bottomRight: Radius.circular(message.isSentByMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        message.isSentByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.asset(
                              message.imageUrl!,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              message.isSentByMe
                                  ? Colors.white
                                  : AppColors.darkGray,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              message.isSentByMe
                                  ? Colors.white70
                                  : AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isSentByMe)
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(message.userIcon),
                  radius: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () {
              // 파일 첨부 기능
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  hintStyle: TextStyle(color: AppColors.mediumGray),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }
}
