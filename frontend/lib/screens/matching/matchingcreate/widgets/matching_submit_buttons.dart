import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:frontend/screens/matching/matchingcreate/widgets/bottomsheet_widget.dart';
import 'package:frontend/services/matching/matching_create.dart';

class MatchingSubmitButtons extends StatefulWidget {
  final Group? selectedGroup;
  final String? selectedTransport;
  final String? selectedFoodCategory;
  final String? selectedTaste;
  final String? request;
  final Map<String, dynamic> guide;
  final int regionId;
  final List<int> tagIds;
  final String? startDate;
  final String? endDate;
  final VoidCallback onCancel;

  const MatchingSubmitButtons({
    Key? key,
    required this.selectedGroup,
    required this.selectedTransport,
    required this.selectedFoodCategory,
    required this.selectedTaste,
    required this.request,
    required this.guide,
    required this.regionId,
    required this.tagIds,
    required this.startDate,
    required this.endDate,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<MatchingSubmitButtons> createState() => _MatchingSubmitButtonsState();
}

class _MatchingSubmitButtonsState extends State<MatchingSubmitButtons> {
  final MatchingCreateService _matchingCreateService = MatchingCreateService();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (widget.startDate == null || widget.endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행 일정을 선택해주세요.')));
      return;
    }
    debugPrint('가이드 정보: ${widget.guide}');
    // 가이드 ID가 없는 경우 임시로 3 사용
    final guideId = widget.guide['id'] ?? 3962115782;
    debugPrint('사용할 가이드 ID: $guideId');

    setState(() => _isLoading = true);

    if (guideId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('가이드 정보가 올바르지 않습니다.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final matchData = await _matchingCreateService.createMatching(
        tagIds: widget.tagIds,
        regionId: widget.regionId,
        guideMemberId: guideId,
        transportation: widget.selectedTransport ?? '',
        foodPreference: widget.selectedFoodCategory ?? '',
        tastePreference: widget.selectedTaste ?? '',
        requirements: widget.request ?? '',
        startDate: widget.startDate!,
        endDate: widget.endDate!,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder:
            (context) => MatchingConfirmBottomSheet(
              selectedGroup: widget.selectedGroup,
              selectedTransport: widget.selectedTransport,
              selectedFoodCategory: widget.selectedFoodCategory,
              selectedTaste: widget.selectedTaste,
              request: widget.request ?? '',
              guide: widget.guide,
              regionId: widget.regionId,
              tagIds: widget.tagIds,
              startDate: widget.startDate!,
              endDate: widget.endDate!,
              matchData: matchData, // API 응답 데이터 전달
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('매칭 생성 중 오류가 발생했습니다: $e')));
      debugPrint('매칭 생성 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        '신청하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
