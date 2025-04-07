import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/matching/matching_main_model.dart';
import 'package:frontend/services/matching/matching_service.dart';

class MatchingProvider with ChangeNotifier {
  final MatchingService _matchingService = MatchingService();
  List<dynamic> _matches = [];
  bool _isLoading = false;
  bool _isGuide = true;
  int _pendingMatchCount = 0;

  List<dynamic> get matches => _matches;
  bool get isLoading => _isLoading;
  bool get isGuide => _isGuide;
  int get pendingMatchCount => _pendingMatchCount;

  Future<void> checkUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole');
      _isGuide = userRole == 'GUIDE';
      notifyListeners();
      await fetchMatches();
    } catch (e) {
      debugPrint('사용자 역할 확인 오류: $e');
      await fetchMatches();
    }
  }

  Future<void> fetchMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isGuide) {
        final guideMatches = await _matchingService.getGuideMatchRequests();
        _matches = guideMatches;
        _pendingMatchCount =
            guideMatches.where((match) => match.status == 'PENDING').length;
      } else {
        final applicantMatches = await _matchingService.getApplicantMatches();
        _matches = applicantMatches;
        _pendingMatchCount =
            applicantMatches.where((match) => match.status == 'PENDING').length;
      }
    } catch (e) {
      debugPrint('매칭 목록 조회 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, int>> getMatchingCounts() async {
    return await _matchingService.getMatchingCounts();
  }
}
