import 'package:flutter/material.dart';

class ChatRoom {
  final int chatRoomId;
  final String name;
  final int participantNum;
  final int groupId;
  final int matchId;

  // UI 개선을 위한 추가 속성
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? unreadCount;
  final String? thumbnailUrl;
  final bool? isActive;
  final bool? isAdmin;

  ChatRoom({
    required this.chatRoomId,
    required this.name,
    required this.participantNum,
    required this.groupId,
    required this.matchId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.thumbnailUrl,
    this.isActive,
    this.isAdmin,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'],
      name: json['name'],
      participantNum: json['participantNum'],
      groupId: json['groupId'],
      matchId: json['matchId'],
      lastMessage: json['lastMessage'],
      lastMessageTime:
          json['lastMessageTime'] != null
              ? DateTime.parse(json['lastMessageTime'])
              : null,
      unreadCount: json['unreadCount'],
      thumbnailUrl: json['thumbnailUrl'],
      isActive: json['isActive'] ?? true,
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}

class ChatMessage {
  final int messageId;
  final int chatRoomId;
  final int memberId;
  final String nickname;
  final String? profileUrl;
  final String messageContent;
  final String messageType;
  final DateTime createdAt;
  final List<String>? imageUrls;

  ChatMessage({
    required this.messageId,
    required this.chatRoomId,
    required this.memberId,
    required this.nickname,
    this.profileUrl,
    required this.messageContent,
    required this.messageType,
    required this.createdAt,
    this.imageUrls,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    List<String>? urls;
    if (json['imageUrls'] != null) {
      urls = List<String>.from(json['imageUrls']);
    }

    return ChatMessage(
      messageId: json['messageId'],
      chatRoomId: json['chatRoomId'],
      memberId: json['memberId'],
      nickname: json['nickname'],
      profileUrl: json['profileUrl'],
      messageContent: json['messageContent'],
      messageType: json['messageType'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrls: urls,
    );
  }
}

class ChatMember {
  final int memberId;
  final String memberNickname;
  final String? profileUrl;
  final DateTime joinedAt;

  ChatMember({
    required this.memberId,
    required this.memberNickname,
    this.profileUrl,
    required this.joinedAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      memberId: json['memberId'],
      memberNickname: json['memberNickname'],
      profileUrl: json['profileUrl'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

class ChatRoomDetail {
  final int chatRoomId;
  final String name;
  final List<ChatMessage> messages;
  final List<ChatMember> members;
  final int matchId;

  ChatRoomDetail({
    required this.chatRoomId,
    required this.name,
    required this.messages,
    required this.members,
    required this.matchId,
  });

  factory ChatRoomDetail.fromJson(Map<String, dynamic> json) {
    return ChatRoomDetail(
      chatRoomId: json['chatRoomId'],
      name: json['name'],
      messages:
          (json['messages'] as List)
              .map((message) => ChatMessage.fromJson(message))
              .toList(),
      members:
          (json['members'] as List)
              .map((member) => ChatMember.fromJson(member))
              .toList(),
      matchId: json['matchId'] ?? 0,
    );
  }
}
