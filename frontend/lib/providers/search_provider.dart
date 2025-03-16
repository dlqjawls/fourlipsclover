// lib/providers/search_provider.dart
import 'package:flutter/material.dart';
import '../models/search_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchProvider extends ChangeNotifier {
  bool _isSearchMode = false;
  List<SearchHistory> _searchHistory = [
    SearchHistory(query: "수완지구 양식", date: "03.14"),
    SearchHistory(query: "수완지구 술집", date: "03.10"),
    SearchHistory(query: "각화동", date: "03.08"),
    SearchHistory(query: "우츠", date: "03.07"),
    SearchHistory(query: "대전", date: "03.07"),
  ];
  
  // 게터
  bool get isSearchMode => _isSearchMode;
  List<SearchHistory> get searchHistory => _searchHistory;
  
  // 검색 모드 전환
  void toggleSearchMode(bool value, [TextEditingController? controller]) {
    _isSearchMode = value;
    
    // 검색 모드로 들어갈 때 텍스트 초기화
    if (value && controller != null) {
      controller.clear();
    }
    
    notifyListeners();
  }
  // 검색 기록 추가
  void addSearchHistory(String query) {
    // 빈 검색어는 추가하지 않음
    if (query.trim().isEmpty) return;
    
    // 오늘 날짜로 새 항목 생성
    final now = DateTime.now();
    final formattedDate = "${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}";
    
    // 중복 방지를 위해 기존 항목 제거
    _searchHistory.removeWhere((item) => item.query == query);
    
    // 새 검색어를 목록 맨 앞에 추가
    _searchHistory.insert(0, SearchHistory(query: query, date: formattedDate));
    
    // 검색 기록이 20개를 넘으면 가장 오래된 기록 삭제
    if (_searchHistory.length > 20) {
      _searchHistory.removeLast();
    }
    
    // 변경사항 저장
    saveSearchHistory();
    notifyListeners();
  }
  
  // 특정 검색 기록 삭제
  void removeSearchHistoryItem(int index) {
    if (index >= 0 && index < _searchHistory.length) {
      _searchHistory.removeAt(index);
      saveSearchHistory();
      notifyListeners();
    }
  }
  
  // 검색 기록 전체 삭제
  void clearSearchHistory() {
    _searchHistory.clear();
    saveSearchHistory();
    notifyListeners();
  }
  
  // SharedPreferences에 검색 기록 저장
  Future<void> saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _searchHistory.map((item) => {
        'query': item.query,
        'date': item.date,
      }).toList();
      await prefs.setString('searchHistory', jsonEncode(jsonList));
    } catch (e) {
      print('검색 기록 저장 오류: $e');
    }
  }
  
  // SharedPreferences에서 검색 기록 불러오기
  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('searchHistory');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        _searchHistory = jsonList.map((item) => SearchHistory(
          query: item['query'],
          date: item['date'],
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print('검색 기록 불러오기 오류: $e');
    }
  }
  
  // Provider 초기화 시 호출
  void initialize() {
    loadSearchHistory();
  }
}