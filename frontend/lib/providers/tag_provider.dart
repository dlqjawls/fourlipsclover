// lib/providers/tag_provider.dart
import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../services/api/tag_api.dart';

class TagProvider with ChangeNotifier {
  List<TagModel> _tags = [];
  bool _isLoading = false;
  String? _error;

  // 게터
  List<TagModel> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 카테고리별로 태그 그룹화
  Map<String, List<TagModel>> get tagsByCategory {
    final Map<String, List<TagModel>> grouped = {};
    
    for (var tag in _tags) {
      if (!grouped.containsKey(tag.category)) {
        grouped[tag.category] = [];
      }
      
      grouped[tag.category]!.add(tag);
    }
    
    return grouped;
  }

  // 태그 이름으로 태그 ID 찾기
  int? getTagIdByName(String name) {
    try {
      final tag = _tags.firstWhere(
        (tag) => tag.name.toLowerCase() == name.toLowerCase(),
      );
      return tag.tagId;
    } catch (e) {
      print('태그를 찾을 수 없음: $name');
      return null; // 태그를 찾지 못한 경우
    }
  }

  // 태그 ID로 태그 이름 찾기
  String? getTagNameById(int id) {
    try {
      final tag = _tags.firstWhere((tag) => tag.tagId == id);
      return tag.name;
    } catch (e) {
      print('ID로 태그를 찾을 수 없음: $id');
      return null; // 태그를 찾지 못한 경우
    }
  }

  // 태그 목록 불러오기
  Future<void> fetchTags() async {
    // 이미 데이터가 있고 로딩 중이 아니라면 즉시 반환
    if (_tags.isNotEmpty && !_isLoading) {
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('태그 목록 불러오기 시작...');
      final tagsList = await TagApi.getTagList();
      _tags = tagsList;
      _isLoading = false;
      print('태그 목록 불러오기 완료: ${_tags.length}개 태그');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('태그 목록 불러오기 오류: $_error');
      notifyListeners();
    }
  }

  // 특정 카테고리의 태그만 필터링해서 반환 (클라이언트 측 필터링)
  List<TagModel> getTagsByCategory(String category) {
    // 전체 태그 중에서 해당 카테고리에 속하는 태그만 필터링
    return _tags.where((tag) => tag.category == category).toList();
  }

  // 태그 데이터 초기화
  void reset() {
    _tags = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}