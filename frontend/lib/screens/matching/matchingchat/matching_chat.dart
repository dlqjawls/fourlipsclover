import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

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
  final List<ChatMessage> _messages = [
    ChatMessage(
      message: '안녕하세요! 매칭이 확정되어서 반갑습니다.',
      isSentByMe: false,
      time: '10:30',
      userName: '김현지',
      userIcon: 'assets/default_profile.png',
    ),
    ChatMessage(
      message: '네, 반갑습니다! 여행 일정에 대해 이야기해볼까요?',
      isSentByMe: true,
      time: '10:31',
      userName: '나',
      userIcon: 'assets/default_profile.png',
    ),
    ChatMessage(
      message: '제가 추천하는 여행 코스입니다.',
      isSentByMe: false,
      time: '10:32',
      imageUrl: 'assets/images/sample_travel.jpg',
      userName: '김현지',
      userIcon: 'assets/default_profile.png',
    ),
    ChatMessage(
      message: '좋아보이네요! 이 코스로 진행해도 될까요?',
      isSentByMe: true,
      time: '10:33',
      userName: '나',
      userIcon: 'assets/default_profile.png',
    ),
  ];

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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          message: _messageController.text,
          isSentByMe: true,
          time: '${DateTime.now().hour}:${DateTime.now().minute}',
          userName: '나',
          userIcon: 'assets/default_profile.png',
        ),
      );
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
