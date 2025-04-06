import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ChatService {
  final String baseUrl = ApiConfig.baseUrl;
  String? _currentUserId;

  Future<String> getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId!;

    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    return _currentUserId ?? '';
  }

  Future<List<Map<String, dynamic>>> getChatHistory(
    String groupId, {
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/$groupId/history?limit=$limit'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> pollNewMessages(
    String groupId, {
    DateTime? lastMessageTime,
  }) async {
    try {
      final queryParams = {
        if (lastMessageTime != null)
          'lastMessageTime': lastMessageTime.toIso8601String(),
      };

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/chat/$groupId/poll',
        ).replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to poll new messages');
      }
    } catch (e) {
      debugPrint('Error polling new messages: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/${message['groupId']}/messages'),
        headers: await _getHeaders(),
        body: json.encode(message),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
