// lib/providers/search_provider.dart
import 'package:flutter/material.dart';
import '../models/search_history.dart';
import '../models/restaurant_model.dart';  // 식당 모델 import
import '../services/api/search_api.dart';      // 검색 API 서비스 import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchProvider extends ChangeNotifier {
  bool _isSearchMode = false;
  List<SearchHistory> _searchHistory = [];
  
  // 검색 결과 상태 추가
  List<RestaurantResponse> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  // 게터
  bool get isSearchMode => _isSearchMode;
  List<SearchHistory> get searchHistory => _searchHistory;
  List<RestaurantResponse> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 검색 모드 전환
  void toggleSearchMode(bool value, [TextEditingController? controller]) {
    _isSearchMode = value;
    
    // 검색 모드로 들어갈 때 텍스트 초기화
    if (value && controller != null) {
      controller.clear();
    }
    
    notifyListeners();
  }
  
  // 검색 결과 가져오기
Future<List<RestaurantResponse>> fetchSearchResults(String query) async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  
  try {
    // 검색 API 호출
    final results = await RestaurantSearchApi.searchRestaurants(query);
    
    // 비동기 작업 완료 후 상태 업데이트
    _searchResults = results;
    _isLoading = false;
    notifyListeners();
    
    return results;
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
    
    print('검색 결과 가져오기 오류: $e');
    return [];
  }
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
  
  // 검색 결과 초기화
  void clearSearchResults() {
    _searchResults = [];
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

  // 클래스 내부에 태그 관련 변수 추가
List<String> _selectedTags = [];

// getter 추가
List<String> get selectedTags => _selectedTags;

// 태그 설정 메소드 추가
void setSelectedTags(List<String> tags) {
  _selectedTags = List.from(tags);
  notifyListeners();
}

// 태그 추가 메소드
void addTag(String tag) {
  if (!_selectedTags.contains(tag)) {
    _selectedTags.add(tag);
    notifyListeners();
  }
}

// 태그 제거 메소드
void removeTag(String tag) {
  _selectedTags.remove(tag);
  notifyListeners();
}

// 태그 초기화 메소드
void clearTags() {
  _selectedTags.clear();
  notifyListeners();
}
}