// lib/screens/group_plan/bottomsheet/schedule_create_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_schedule_create_request.dart';
import '../../../providers/plan_provider.dart';
import '../../../widgets/clover_loading_spinner.dart';
import '../../../config/theme.dart';

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
  State<ScheduleCreateBottomSheet> createState() => _ScheduleCreateBottomSheetState();
}

class _ScheduleCreateBottomSheetState extends State<ScheduleCreateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // 장소 정보 - kakaoPlaceId 사용 (또는 restaurantId 사용 가능)
  int? _restaurantId;
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

  // 날짜 선택 다이얼로그 표시
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  // 시간 선택 다이얼로그 표시
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _visitTime) {
      setState(() {
        _visitTime = picked;
      });
    }
  }

  // 일정 생성 요청 처리
  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일정이 추가되었습니다.')),
        );
        
        // 콜백 호출 및 바텀시트 닫기
        if (widget.onScheduleCreated != null) {
          widget.onScheduleCreated!();
        }
        Navigator.pop(context);
      }
    } catch (e) {
      // 에러 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정 추가에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 장소 검색 기능 (카카오맵 API 연동 예정)
  Future<void> _searchPlace() async {
    // TODO: 카카오맵 API 연동 장소 검색 기능 구현
    // 현재는 임시로 더미 데이터 사용
    
    // 장소 검색 결과 예시
    setState(() {
      _restaurantId = 1;
      _placeName = '초돈'; // 실제 구현 시 선택한 장소 이름 사용
    });
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
                const Text(
                  '일정 추가하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                                  color: _placeName.isEmpty
                                      ? Colors.grey.shade500
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
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
                
                // 방문 날짜 필드
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '방문 날짜',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
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
                                DateFormat('yyyy년 MM월 dd일').format(_visitDate),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
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
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _visitTime.format(context),
                              ),
                            ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // 하단 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 저장 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _placeName.isEmpty ? null : _createSchedule,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}