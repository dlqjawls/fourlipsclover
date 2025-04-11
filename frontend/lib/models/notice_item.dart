// lib/models/notice_item.dart

import 'package:flutter/material.dart';

class NoticeItem {
  final String id;
  final String content;
  final Color color;
  final bool isImportant;
  final DateTime createdAt;

  NoticeItem({
    required this.id,
    required this.content,
    required this.color,
    required this.isImportant,
    required this.createdAt,
  });
}