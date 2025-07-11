import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/plan/plan_model.dart';
import '../../../../models/plan/plan_schedule_model.dart';
import '../../../../models/plan/plan_schedule_update_request.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../config/theme.dart';
import '../../../../widgets/toast_bar.dart';
import 'custom_time_picker.dart';

class ScheduleUpdateBottomSheet extends StatefulWidget {
  final int groupId;
  final int planId;
  final PlanSchedule schedule;
  final Function onScheduleUpdated;
  final DateTime startDate; // 여행 시작일
  final DateTime endDate; // 여행 종료일

  const ScheduleUpdateBottomSheet({
    Key? key,
    required this.groupId,
    required this.planId,
    required this.schedule,
    required this.onScheduleUpdated,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<ScheduleUpdateBottomSheet> createState() =>
      _ScheduleUpdateBottomSheetState();
}

class _ScheduleUpdateBottomSheetState extends State<ScheduleUpdateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  // 일정 상세 정보에서 가져올 restaurantId
  int? _restaurantId;

  @override
  void initState() {
    super.initState();

    // 기존 일정 데이터로 초기화
    _selectedDate = DateTime(
      widget.schedule.visitAt.year,
      widget.schedule.visitAt.month,
      widget.schedule.visitAt.day,
    );

    _selectedTime = TimeOfDay(
      hour: widget.schedule.visitAt.hour,
      minute: widget.schedule.visitAt.minute,
    );

    if (widget.schedule.notes != null) {
      _notesController.text = widget.schedule.notes!;
    }

    // 일정 상세 정보 조회
    _fetchScheduleDetail();
  }

  // 일정 상세 정보를 조회하는 메서드
  Future<void> _fetchScheduleDetail() async {
    setState(() {
      _isLoading = false;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);

      // 참고: PlanProvider에 이 메서드가 구현되어 있어야 합니다.
      // 없다면 PlanProvider에 추가해야 함
      final scheduleDetail = await planProvider.getPlanScheduleDetail(
        widget.groupId,
        widget.planId,
        widget.schedule.planScheduleId,
      );

      // 찾은 정보에서 restaurantId 가져오기
      if (scheduleDetail.restaurant != null) {
        setState(() {
          _restaurantId = scheduleDetail.restaurant.restaurantId;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastBar.clover('일정 상세 정보 로드 실패');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // 날짜 선택 다이얼로그 표시 - 여행 기간으로 제한
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.startDate,
      lastDate: widget.endDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 시간 선택 - CustomTimePicker 사용
  void _selectTime(BuildContext context) {
    CustomTimePicker.show(
      context: context,
      initialTime: _selectedTime,
      onTimeSelected: (TimeOfDay time) {
        setState(() {
          _selectedTime = time;
        });
      },
    );
  }

  // 일정 업데이트
  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 선택한 날짜와 시간 결합
      final updatedVisitAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // 업데이트 요청 생성
      final request = PlanScheduleUpdateRequest(
        visitAt: updatedVisitAt,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        restaurantId: _restaurantId, // 조회한 restaurantId 사용
      );

      // 디버그 출력
      debugPrint('일정 수정 요청: ${request.toJson()}');

      // PlanProvider를 통해 업데이트 요청
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      await planProvider.updatePlanSchedule(
        groupId: widget.groupId,
        planId: widget.planId,
        scheduleId: widget.schedule.planScheduleId,
        request: request,
      );

      widget.onScheduleUpdated();

      if (mounted) {
        Navigator.pop(context);
        ToastBar.clover('일정 수정 완료');
      }
    } catch (e) {
      if (mounted) {
        ToastBar.clover('일정 수정 실패');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기 로딩 중이면 로딩 인디케이터 표시
    if (_isLoading && _restaurantId == null) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 형식화된 날짜 및 시간 문자열
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(_selectedDate);
    final timeStr = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(DateTime(2022, 1, 1, _selectedTime.hour, _selectedTime.minute));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 핸들
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

              // 타이틀
              const Center(
                child: Text(
                  '일정 수정하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // 장소명 표시 (수정 불가)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.verylightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.schedule.placeName ?? '알 수 없는 장소',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 방문 날짜 및 시간 선택
              Row(
                children: [
                  // 날짜 선택
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 시간 선택
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 메모 입력
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '메모',
                  hintText: '방문에 대한 메모를 남겨보세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 수정 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
