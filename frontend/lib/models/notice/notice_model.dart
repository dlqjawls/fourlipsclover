// lib/models/notice/notice_model.dart

import 'package:flutter/foundation.dart';

enum NoticeColor { YELLOW, RED, BLUE, GREEN, ORANGE, VIOLET }

extension NoticeColorExtension on NoticeColor {
  // 색상 이름을 문자열로 변환 (서버 통신용)
  String toServerString() {
    return this.toString().split('.').last;
  }

  // 서버 문자열에서 NoticeColor 열거형으로 변환
  static NoticeColor fromServerString(String str) {
    return NoticeColor.values.firstWhere(
      (e) => e.toString().split('.').last == str,
      orElse: () => NoticeColor.YELLOW, // 기본값
    );
  }
}

class NoticeModel {
  final int? planNoticeId; // 생성 시에는 null
  final int planId;
  final int? creatorId; // 생성 시에는 백엔드에서 주입
  final bool isImportant;
  final NoticeColor color;
  final String content;
  final DateTime? createdAt; // 생성 시에는 백엔드에서 주입
  final DateTime? updatedAt; // 생성 시에는 null

  NoticeModel({
    this.planNoticeId,
    required this.planId,
    this.creatorId,
    required this.isImportant,
    required this.color,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  // JSON에서 변환
  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      planNoticeId: json['planNoticeId'],
      planId: json['planId'],
      creatorId: json['creatorId'],
      isImportant: json['important'] ?? false, // 'important' 필드 사용
      color: NoticeColorExtension.fromServerString(json['color'] ?? 'YELLOW'),
      content: json['content'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'important': isImportant, // 'isImportant'에서 'important'로 변경
      'color': color.toServerString(),
      'content': content,
    };
  }

  // 기존 객체를 기반으로 새 객체 생성
  NoticeModel copyWith({
    int? planNoticeId,
    int? planId,
    int? creatorId,
    bool? isImportant,
    NoticeColor? color,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoticeModel(
      planNoticeId: planNoticeId ?? this.planNoticeId,
      planId: planId ?? this.planId,
      creatorId: creatorId ?? this.creatorId,
      isImportant: isImportant ?? this.isImportant,
      color: color ?? this.color,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
