// lib/screens/group_plan/bottomsheet/schedule_create_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/plan/plan_model.dart';
import '../../../../models/plan/plan_schedule_create_request.dart';
import '../../../../models/restaurant_model.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../widgets/clover_loading_spinner.dart';
import '../../../../config/theme.dart';
import '../../../../widgets/toast_bar.dart';
import 'custom_time_picker.dart';
import 'restaurant_search_screen.dart';

class ScheduleCreateBottomSheet extends StatefulWidget {
  final int groupId;
  final int planId;
  final DateTime? initialDate;
  final Function? onScheduleCreated;

  const ScheduleCreateBottomSheet({
    Key? key,
    required this.groupId,
    required this.planId,
    this.initialDate,
    this.onScheduleCreated,
  }) : super(key: key);

  @override
  State<ScheduleCreateBottomSheet> createState() =>
      _ScheduleCreateBottomSheetState();
}

class _ScheduleCreateBottomSheetState extends State<ScheduleCreateBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // 장소 정보
  int? _restaurantId;
  String? _kakaoPlaceId;
  String _placeName = '';

  // 방문 날짜 및 시간
  late DateTime _visitDate;
  TimeOfDay _visitTime = const TimeOfDay(hour: 12, minute: 0);

  // 메모
  final TextEditingController _notesController = TextEditingController();

  // 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 날짜 설정
    _visitDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // 시간 선택 다이얼로그 표시
  void _selectTime(BuildContext context) {
    CustomTimePicker.show(
      context: context,
      initialTime: _visitTime,
      onTimeSelected: (TimeOfDay pickedTime) {
        setState(() {
          _visitTime = pickedTime;
        });
      },
    );
  }

  // 일정 생성 요청 처리
  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // 유효성 검사 - 레스토랑 ID 또는 kakaoPlaceId 중 하나는 있어야 함
    if (_restaurantId == null && _kakaoPlaceId == null) {
      ToastBar.clover('방문 장소를 선택해주세요.');
      return;
    }

    // 방문 일시 생성 (날짜 + 시간)
    final visitDateTime = DateTime(
      _visitDate.year,
      _visitDate.month,
      _visitDate.day,
      _visitTime.hour,
      _visitTime.minute,
    );

    // 요청 데이터 생성
    final request = PlanScheduleCreateRequest(
      restaurantId: _restaurantId,
      kakaoPlaceId: _kakaoPlaceId,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      visitAt: visitDateTime,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // Provider를 통한 API 호출
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      await planProvider.createPlanSchedule(
        groupId: widget.groupId,
        planId: widget.planId,
        request: request,
      );

      // 성공 메시지
      if (mounted) {
        ToastBar.clover('일정 추가 완료');

        // 콜백 호출 - Navigator.pop 전에 호출해야 부모 위젯이 업데이트를 감지할 수 있음
        if (widget.onScheduleCreated != null) {
          widget.onScheduleCreated!();
        }

        // 바텀시트 닫기 - 명시적으로 context 확인 후 팝
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // 에러 메시지
      if (mounted) {
        ToastBar.clover('일정 추가 실패');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 장소 검색 화면으로 이동
  Future<void> _searchPlace() async {
    // RestaurantSearchScreen으로 이동하여 결과 받기
    final result = await Navigator.push<RestaurantResponse>(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantSearchScreen()),
    );

    // 결과가 있는 경우 상태 업데이트
    if (result != null) {
      setState(() {
        _restaurantId = result.restaurantId;
        _kakaoPlaceId = result.kakaoPlaceId;
        _placeName = result.placeName ?? '이름 없음';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단 헤더
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 제목
                const Center(
                  child: Text(
                    '일정 추가하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                // 장소 검색 필드
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '방문 장소',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _searchPlace,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _placeName.isEmpty ? '장소를 검색해주세요' : _placeName,
                                style: TextStyle(
                                  color:
                                      _placeName.isEmpty
                                          ? AppColors.mediumGray
                                          : Colors.black,
                                ),
                              ),
                            ),
                            Icon(Icons.search, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    if (_placeName.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          '방문할 장소를 선택해주세요',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // 방문 시간 필드
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '방문 시간',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(_visitTime.format(context))),
                            Icon(
                              Icons.access_time,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 메모 필드
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '메모 (선택사항)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '메모를 입력해주세요',
                        hintStyle: TextStyle(color: AppColors.mediumGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.lightGray),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.lightGray),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 저장 버튼 (전체 너비)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placeName.isEmpty ? null : _createSchedule,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
