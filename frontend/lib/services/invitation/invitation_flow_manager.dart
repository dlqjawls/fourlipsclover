// lib/services/invitation_flow_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationFlowManager {
  static const String _pendingTokenKey = 'pendingInvitationToken';
  
  // 초대 토큰 저장
  static Future<void> saveInvitationToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingTokenKey, token);
  }
  
  // 저장된 초대 토큰 가져오기
  static Future<String?> getPendingInvitationToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingTokenKey);
  }
  
  // 초대 토큰 삭제
  static Future<void> clearPendingInvitationToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingTokenKey);
  }
}