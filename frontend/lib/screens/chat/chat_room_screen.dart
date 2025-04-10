import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/plan_provider.dart';
import 'package:frontend/models/plan/plan_model.dart';
import 'package:frontend/models/plan/plan_schedule_model.dart';
import 'package:frontend/models/plan/plan_list_model.dart';
import 'package:frontend/screens/group_plan/plan_widgets/timeline_card.dart';
import 'package:frontend/screens/group_plan/bottomsheet/schedule_detail_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;
  final int groupId;

  const ChatRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.groupId,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

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

  // 계획 관련 상태 변수들
  List<PlanList> _availablePlans = [];
  PlanList? _selectedPlan;
  List<PlanSchedule> _planSchedules = [];
  Timer? _schedulePollingTimer;
  bool _isLoadingPlans = false;
  bool _isLoadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadChatRoom();
    _startPolling();
    _scrollController.addListener(_onScroll);
    _startSchedulePolling(); // 일정 폴링 시작
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _schedulePollingTimer?.cancel();
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

  // 일정 폴링 시작
  void _startSchedulePolling() {
    _schedulePollingTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) {
      if (_selectedPlan != null) {
        _loadPlanSchedules();
      }
    });
  }

  // 계획 목록 로드
  Future<void> _loadAvailablePlans() async {
    if (_isLoadingPlans) return;

    setState(() {
      _isLoadingPlans = true;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final plans = await planProvider.fetchPlans(widget.groupId);
      setState(() {
        _availablePlans = plans;
      });
    } catch (e) {
      String errorMessage = '계획 목록을 불러오는데 실패했습니다.';

      if (e.toString().contains('403')) {
        errorMessage = '그룹에 대한 접근 권한이 없습니다.';
      } else if (e.toString().contains('404')) {
        errorMessage = '그룹을 찾을 수 없습니다.';
      } else if (e.toString().contains('500')) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }

      // 에러 메시지를 스낵바로 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('계획 목록 로드 중 오류: $e');
    } finally {
      setState(() {
        _isLoadingPlans = false;
      });
    }
  }

  // 일정 목록 로드
  Future<void> _loadPlanSchedules() async {
    if (_selectedPlan == null || _isLoadingSchedules) return;

    setState(() {
      _isLoadingSchedules = true;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      final schedules = await planProvider.fetchPlanSchedules(
        widget.groupId,
        _selectedPlan!.planId,
      );
      setState(() {
        _planSchedules = schedules;
      });
    } catch (e) {
      debugPrint('일정 목록 로드 중 오류: $e');
    } finally {
      setState(() {
        _isLoadingSchedules = false;
      });
    }
  }

  // 계획 선택 다이얼로그 표시
  Future<void> _showPlanSelectionDialog() async {
    if (_availablePlans.isEmpty) {
      await _loadAvailablePlans();
    }

    if (_availablePlans.isEmpty) {
      // 계획이 없는 경우 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용 가능한 계획이 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('계획 선택'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  _isLoadingPlans
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availablePlans.length,
                        itemBuilder: (context, index) {
                          final plan = _availablePlans[index];
                          return ListTile(
                            title: Text(plan.title),
                            subtitle: Text(
                              '${DateFormat('yyyy-MM-dd').format(plan.startDate)} ~ ${DateFormat('yyyy-MM-dd').format(plan.endDate)}',
                            ),
                            onTap: () {
                              setState(() {
                                _selectedPlan = plan;
                              });
                              _loadPlanSchedules();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ],
          ),
    );
  }

  void _showImagePicker() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
        });
        _showImagePreview();
      }
    } catch (e) {
      debugPrint('이미지 선택 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다')));
    }
  }

  void _showImagePreview() {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('선택한 이미지'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                  if (_selectedImages.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요 (선택)',
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
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectedImages.clear();
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendImages(messageController.text.trim());
                },
                child: const Text('전송'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendImages(String messageContent) async {
    if (_selectedImages.isEmpty) return;

    try {
      // 이미지 메시지 전송
      final message = await _chatService.sendImageMessage(
        widget.chatRoomId,
        messageContent.isNotEmpty
            ? messageContent
            : '이미지 ${_selectedImages.length}장',
        _selectedImages,
      );

      setState(() {
        _chatRoom!.messages.insert(0, message);
        _lastMessageTime = message.createdAt;
        _shouldAutoScroll = true;
        _selectedImages.clear();
      });

      // 메시지 전송 후 즉시 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('이미지 전송 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 전송 중 오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreOptions,
            ),
          ],
        ),
        body: Column(
          children: [Expanded(child: _buildBody()), _buildMessageInput()],
        ),
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            onPressed: _showOptionsMenu,
          ),
          const SizedBox(width: 8),
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

  void _showOptionsMenu() {
    FocusScope.of(context).unfocus(); // 키보드 숨기기
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(16),
          children: [
            _buildOptionItem(Icons.image, '이미지 보내기', _showImagePicker),
            _buildOptionItem(Icons.person_add, '초대하기', _inviteMembers),
          ],
        );
      },
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, size: 30), onPressed: onTap),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _inviteMembers() {
    // TODO: 초대 기능 구현
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('초대 기능은 아직 구현되지 않았습니다.')));
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('이미지 전송'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePicker();
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('채팅방 나가기'),
                onTap: () {
                  Navigator.pop(context);
                  _showLeaveChatRoomDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('신고하기'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('차단하기'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLeaveChatRoomDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('채팅방 나가기'),
            content: const Text('정말로 채팅방을 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _chatService.leaveChatRoom(widget.chatRoomId);
                    if (mounted) {
                      Navigator.pop(context); // 다이얼로그 닫기
                      Navigator.pop(context); // 채팅방 화면 닫기
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('채팅방 나가기 실패: $e')));
                    }
                  }
                },
                child: const Text('나가기'),
              ),
            ],
          ),
    );
  }

  void _showReportDialog() {
    // TODO: 신고 기능 구현
  }

  void _showBlockDialog() {
    // TODO: 차단 기능 구현
  }
}
