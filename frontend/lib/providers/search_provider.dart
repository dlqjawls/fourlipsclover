// lib/providers/search_provider.dart
import 'package:flutter/material.dart';
import '../models/search_history.dart';
import '../models/restaurant_model.dart';  // 식당 모델 import
import '../services/api/search_api.dart';  // 검색 API 서비스 import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchProvider extends ChangeNotifier {
  bool _isSearchMode = false;
  List<SearchHistory> _searchHistory = [];
  
  // 검색 결과 상태 추가
  List<RestaurantResponse> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  // 위치 관련 상태 추가
  String? _lastLocation;
  double? _lastLatitude;
  double? _lastLongitude;
  
  // 태그 관련 상태
  List<String> _selectedTags = [];
  List<int> _selectedTagIds = []; // 태그 ID 목록 추가
  Map<String, int> _tagToIdMap = {}; // 태그 이름과 ID 매핑
  
  // 게터
  bool get isSearchMode => _isSearchMode;
  List<SearchHistory> get searchHistory => _searchHistory;
  List<RestaurantResponse> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get selectedTags => _selectedTags;
  List<int> get selectedTagIds => _selectedTagIds;
  
  // 위치 정보 getter
  String? get lastLocation => _lastLocation;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  
  // 검색 모드 전환
  void toggleSearchMode(bool value, [TextEditingController? controller]) {
    _isSearchMode = value;
    
    // 검색 모드로 들어갈 때 텍스트 초기화
    if (value && controller != null) {
      controller.clear();
    }
    
    notifyListeners();
  }
  
  // 검색 결과 가져오기 (태그 ID 및 위치 기반 검색 지원)
  Future<List<RestaurantResponse>> fetchSearchResults(
    String query, {
    List<int>? tagIds,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 태그 ID가 제공되지 않으면 현재 선택된 태그 ID 사용
      tagIds = tagIds ?? _selectedTagIds;
      
      // 위치 정보가 제공되지 않으면 마지막 위치 사용
      latitude = latitude ?? _lastLatitude;
      longitude = longitude ?? _lastLongitude;
      
      // 검색 API 호출
      final results = await RestaurantSearchApi.searchRestaurants(
        query,
        tagIds: tagIds.isNotEmpty ? tagIds : null,
        latitude: latitude,
        longitude: longitude,
      );
      
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
  
  // 앱이 시작될 때 호출되는 초기화 메소드 확장
  Future<void> initialize({bool resetTags = false}) async {
    print('SearchProvider: 초기화 (태그 초기화: $resetTags)');
    await loadSearchHistory();
    
    if (resetTags) {
      clearTags();
    } else {
      await loadSelectedTags();
      await loadSelectedTagIds();
      await loadTagToIdMap(); // 태그-ID 매핑 로드
    }
  }

  // 태그 설정 메소드
  void setSelectedTags(List<String> tags) {
    print('SearchProvider: 태그 설정 시작 - 기존: $_selectedTags, 새로운: $tags');
    
    // 중요: 명시적인 복사와 동등성 비교 추가
    if (tags.length != _selectedTags.length || 
        !tags.every((tag) => _selectedTags.contains(tag))) {
      
      // 깊은 복사를 사용하여 새 리스트 생성
      _selectedTags = List<String>.from(tags);
      
      // 추가 로깅
      print('SearchProvider: 태그 설정 완료 - $_selectedTags');
      
      // 저장과 알림 실행
      saveSelectedTags();
      notifyListeners();
    } else {
      print('SearchProvider: 태그가 동일하여 변경 없음');
    }
  }

  // 태그 추가 메소드
  void addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      _selectedTags.add(tag);
      saveSelectedTags();
      notifyListeners();
    }
  }
  
  // 태그 ID 추가 메소드
  void addTagId(int tagId) {
    if (!_selectedTagIds.contains(tagId)) {
      _selectedTagIds.add(tagId);
      saveSelectedTagIds();
      notifyListeners();
    }
  }

  // 태그와 태그 ID 함께 추가 메소드
  void addTagWithId(String tag, int tagId) {
    bool changed = false;
    
    if (!_selectedTags.contains(tag)) {
      _selectedTags.add(tag);
      changed = true;
    }
    
    if (!_selectedTagIds.contains(tagId)) {
      _selectedTagIds.add(tagId);
      changed = true;
    }
    
    // 태그-ID 매핑 추가
    _tagToIdMap[tag] = tagId;
    
    if (changed) {
      saveSelectedTags();
      saveSelectedTagIds();
      saveTagToIdMap(); // 매핑 저장
      notifyListeners();
    }
  }

  // 태그 제거 메소드 (해당 태그 ID도 함께 제거)
  void removeTag(String tag) {
    // 태그 이름 제거
    _selectedTags.remove(tag);
    
    // 매핑에서 ID 찾아 제거
    if (_tagToIdMap.containsKey(tag)) {
      int tagId = _tagToIdMap[tag]!;
      _selectedTagIds.remove(tagId);
      _tagToIdMap.remove(tag);
    }
    
    saveSelectedTags();
    saveSelectedTagIds();
    saveTagToIdMap(); // 매핑 저장
    notifyListeners();
  }

  // 태그 ID로 제거하는 메소드
  void removeTagId(int tagId) {
    _selectedTagIds.remove(tagId);
    
    // 매핑에서 해당 ID를 갖는 태그 찾아 제거
    String? tagToRemove;
    _tagToIdMap.forEach((tag, id) {
      if (id == tagId) {
        tagToRemove = tag;
      }
    });
    
    if (tagToRemove != null) {
      _selectedTags.remove(tagToRemove);
      _tagToIdMap.remove(tagToRemove);
    }
    
    saveSelectedTagIds();
    saveSelectedTags();
    saveTagToIdMap(); // 매핑 저장
    notifyListeners();
  }

  // 태그 초기화 메소드
  void clearTags() {
    _selectedTags.clear();
    _selectedTagIds.clear();
    _tagToIdMap.clear();
    saveSelectedTags();
    saveSelectedTagIds();
    saveTagToIdMap(); // 매핑 저장
    notifyListeners();
  }

  // 검색 완료 후 홈 화면으로 돌아갈 때 호출되는 메소드
  void completeSearch() {
    print('SearchProvider: 검색 완료 처리');
    // 태그는 유지하고 검색 모드만 비활성화
    _isSearchMode = false;
    notifyListeners();
  }
  
  // 위치 정보 설정
  void setLastLocation(String location, double latitude, double longitude) {
    _lastLocation = location;
    _lastLatitude = latitude;
    _lastLongitude = longitude;
    notifyListeners();
  }
  
  // 선택된 태그 저장 (SharedPreferences 사용)
  Future<void> saveSelectedTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedTags', _selectedTags);
    } catch (e) {
      print('태그 저장 오류: $e');
    }
  }
  
  // 선택된 태그 불러오기 (SharedPreferences 사용)
  Future<void> loadSelectedTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tags = prefs.getStringList('selectedTags');
      if (tags != null) {
        _selectedTags = tags;
        notifyListeners();
      }
    } catch (e) {
      print('태그 불러오기 오류: $e');
    }
  }
  
  // 선택된 태그 ID 저장 (SharedPreferences 사용)
  Future<void> saveSelectedTagIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagIdStrings = _selectedTagIds.map((id) => id.toString()).toList();
      await prefs.setStringList('selectedTagIds', tagIdStrings);
    } catch (e) {
      print('태그 ID 저장 오류: $e');
    }
  }
  
  // 선택된 태그 ID 불러오기 (SharedPreferences 사용)
  Future<void> loadSelectedTagIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagIdStrings = prefs.getStringList('selectedTagIds');
      if (tagIdStrings != null) {
        _selectedTagIds = tagIdStrings
            .map((idStr) => int.tryParse(idStr))
            .where((id) => id != null)
            .map((id) => id!)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('태그 ID 불러오기 오류: $e');
    }
  }
  
  // 태그-ID 매핑 저장 (SharedPreferences 사용)
  Future<void> saveTagToIdMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapJson = jsonEncode(_tagToIdMap);
      await prefs.setString('tagToIdMap', mapJson);
    } catch (e) {
      print('태그-ID 매핑 저장 오류: $e');
    }
  }
  
  // 태그-ID 매핑 불러오기 (SharedPreferences 사용)
  Future<void> loadTagToIdMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapJson = prefs.getString('tagToIdMap');
      if (mapJson != null) {
        final Map<String, dynamic> decodedMap = jsonDecode(mapJson);
        _tagToIdMap = decodedMap.map((key, value) => MapEntry(key, value as int));
        notifyListeners();
      }
    } catch (e) {
      print('태그-ID 매핑 불러오기 오류: $e');
    }
  }
}