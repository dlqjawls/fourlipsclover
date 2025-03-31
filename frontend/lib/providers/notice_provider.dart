// lib/providers/notice_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/notice/notice_model.dart';
import '../services/api/notice_api.dart';
import '../config/theme.dart';

class NoticeProvider with ChangeNotifier {
  final NoticeApi _noticeApi = NoticeApi();

  // 계획별 공지사항 저장
  final Map<int, List<NoticeModel>> _notices = {}; // planId를 키로 사용

  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NoticeModel> getNoticesForPlan(int planId) => _notices[planId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 로딩 상태 설정
  void setLoading(bool loading) {
    // 현재 값과 다를 때만 업데이트
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // 에러 메시지 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 계획의 공지사항 목록 조회
  Future<List<NoticeModel>> fetchNotices(int planId) async {
    setLoading(true);
    try {
      final notices = await _noticeApi.getNotices(planId);

      // 중요 공지사항을 먼저 정렬
      notices.sort((a, b) {
        if (a.isImportant && !b.isImportant) return -1;
        if (!a.isImportant && b.isImportant) return 1;
        // 생성일 기준 최신순 정렬
        return (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        );
      });

      _notices[planId] = notices;
      _error = null;
      notifyListeners();
      return notices;
    } catch (e) {
      _error = '공지사항 목록을 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      setLoading(false);
    }
  }

  // 공지사항 생성
  Future<NoticeModel> createNotice(int planId, NoticeModel notice) async {
    setLoading(true);
    try {
      final createdNotice = await _noticeApi.createNotice(planId, notice);

      // 캐시 업데이트
      if (_notices.containsKey(planId)) {
        // 중요 공지사항은 앞쪽에, 일반 공지사항은 뒤쪽에 추가
        if (createdNotice.isImportant) {
          // 기존 중요 공지사항의 마지막 위치 찾기
          final lastImportantIndex = _notices[planId]!.lastIndexWhere(
            (n) => n.isImportant,
          );
          if (lastImportantIndex != -1) {
            _notices[planId]!.insert(lastImportantIndex + 1, createdNotice);
          } else {
            _notices[planId]!.insert(0, createdNotice);
          }
        } else {
          _notices[planId]!.add(createdNotice);
        }
      } else {
        _notices[planId] = [createdNotice];
      }

      notifyListeners();
      _error = null;
      return createdNotice;
    } catch (e) {
      _error = '공지사항 생성에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      setLoading(false);
    }
  }

  // 공지사항 수정
  Future<NoticeModel> updateNotice(
    int planId,
    int planNoticeId,
    NoticeModel notice,
  ) async {
    setLoading(true);
    try {
      final updatedNotice = await _noticeApi.updateNotice(planNoticeId, notice);

      // 캐시 업데이트
      if (_notices.containsKey(planId)) {
        final index = _notices[planId]!.indexWhere(
          (n) => n.planNoticeId == planNoticeId,
        );
        if (index != -1) {
          _notices[planId]![index] = updatedNotice;

          // 중요 속성이 변경되었으면 정렬 갱신
          if (_notices[planId]![index].isImportant !=
              updatedNotice.isImportant) {
            _sortNotices(planId);
          }
        }
      }

      notifyListeners();
      _error = null;
      return updatedNotice;
    } catch (e) {
      _error = '공지사항 수정에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      setLoading(false);
    }
  }

  // 공지사항 삭제
  Future<void> deleteNotice(int planId, int planNoticeId) async {
    setLoading(true);
    try {
      await _noticeApi.deleteNotice(planNoticeId);

      // 캐시에서 삭제
      if (_notices.containsKey(planId)) {
        _notices[planId]!.removeWhere(
          (notice) => notice.planNoticeId == planNoticeId,
        );
        notifyListeners();
      }

      _error = null;
    } catch (e) {
      _error = '공지사항 삭제에 실패했습니다: $e';
      debugPrint(_error);
      throw Exception(_error);
    } finally {
      setLoading(false);
    }
  }

  // 공지사항 정렬 (중요 공지사항 먼저)
  void _sortNotices(int planId) {
    if (_notices.containsKey(planId)) {
      _notices[planId]!.sort((a, b) {
        if (a.isImportant && !b.isImportant) return -1;
        if (!a.isImportant && b.isImportant) return 1;
        return (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        );
      });
    }
  }

  // 컬러 변환 헬퍼
  Color getColorFromNoticeColor(NoticeColor color) {
    switch (color) {
      case NoticeColor.YELLOW:
        return AppColors.noticeMemoYellow;
      case NoticeColor.RED:
        return AppColors.noticeMemoRed;
      case NoticeColor.BLUE:
        return AppColors.noticeMemoBlue;
      case NoticeColor.GREEN:
        return AppColors.noticeMemoGreen;
      case NoticeColor.ORANGE:
        return AppColors.noticeMemoOrange;
      case NoticeColor.VIOLET:
        return AppColors.noticeMemoViolet;
      default:
        return AppColors.noticeMemoYellow;
    }
  }

  // NoticeColor 열거형으로 Color 객체 변환
  NoticeColor getNoticeColorFromColor(Color color) {
    if (color == AppColors.noticeMemoYellow) return NoticeColor.YELLOW;
    if (color == AppColors.noticeMemoRed) return NoticeColor.RED;
    if (color == AppColors.noticeMemoBlue) return NoticeColor.BLUE;
    if (color == AppColors.noticeMemoGreen) return NoticeColor.GREEN;
    if (color == AppColors.noticeMemoOrange) return NoticeColor.ORANGE;
    if (color == AppColors.noticeMemoViolet) return NoticeColor.VIOLET;
    return NoticeColor.YELLOW; // 기본값
  }
}
