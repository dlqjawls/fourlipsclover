import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../config/theme.dart';

class PlanScheduleView extends StatefulWidget {
  final Plan plan;
  final int groupId;

  const PlanScheduleView({
    Key? key,
    required this.plan,
    required this.groupId,
  }) : super(key: key);

  @override
  State<PlanScheduleView> createState() => _PlanScheduleViewState();
}

class _PlanScheduleViewState extends State<PlanScheduleView> {
  List<PlanSchedule> _schedules = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final List<DateTime> _travelDates = [];

  @override
  void initState() {
    super.initState();
    // 여행 기간 동안의 날짜 목록 생성
    _generateTravelDates();
    
    // 여행 첫날을 기본 선택 날짜로 설정
    if (_travelDates.isNotEmpty) {
      _selectedDate = _travelDates.first;
    }
    
    // 일정 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  // 여행 기간 동안의 날짜 목록 생성
  void _generateTravelDates() {
    _travelDates.clear();
    DateTime currentDate = widget.plan.startDate;
    
    while (!currentDate.isAfter(widget.plan.endDate)) {
      _travelDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  // 일정 데이터 로드
  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      
      // 계획의 모든 일정 로드
      final schedules = await planProvider.fetchPlanSchedules(
        widget.groupId,
        widget.plan.planId,
      );
      
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('일정 데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  // 선택된 날짜의 일정만 필터링
  List<PlanSchedule> _getSchedulesForSelectedDate() {
    return _schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.visitAt.year,
        schedule.visitAt.month,
        schedule.visitAt.day,
      );
      final targetDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return scheduleDate.isAtSameMomentAs(targetDate);
    }).toList()
      ..sort((a, b) => a.visitAt.compareTo(b.visitAt)); // 시간순 정렬
  }

  // 일정 추가 다이얼로그 표시
  void _showAddScheduleDialog() {
    // 일정 추가 다이얼로그 구현 예정
    // showDialog(
    //   context: context,
    //   builder: (context) => PlanScheduleAddDialog(
    //     planId: widget.plan.planId,
    //     groupId: widget.groupId,
    //     selectedDate: _selectedDate,
    //     onScheduleAdded: _loadSchedules,
    //   ),
    // );
    
    // 임시: 스낵바로 알림
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정 추가 기능은 현재 개발 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 일정 가져오기
    final selectedDateSchedules = _getSchedulesForSelectedDate();
    
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // 날짜 선택 탭 (가로 스크롤)
          Container(
            height: 70,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _travelDates.length,
              itemBuilder: (context, index) {
                final date = _travelDates[index];
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;
                
                // 이 날짜에 일정이 있는지 확인
                final hasSchedules = _schedules.any((schedule) {
                  final scheduleDate = DateTime(
                    schedule.visitAt.year,
                    schedule.visitAt.month,
                    schedule.visitAt.day,
                  );
                  final targetDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                  return scheduleDate.isAtSameMomentAs(targetDate);
                });
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 요일
                        Text(
                          DateFormat('E', 'ko_KR').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                        // 날짜
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.darkGray,
                          ),
                        ),
                        // 일정 표시 점
                        if (hasSchedules)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 상단 정보 및 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '일정 ${selectedDateSchedules.length}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddScheduleDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('일정 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 일정 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedDateSchedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '이 날의 일정이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '새로운 일정을 추가해보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedDateSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = selectedDateSchedules[index];
                          return _buildScheduleItem(schedule, index, selectedDateSchedules);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 일정 아이템 UI
  Widget _buildScheduleItem(PlanSchedule schedule, int index, List<PlanSchedule> schedules) {
    // 시간 포맷팅
    final timeStr = DateFormat('HH:mm').format(schedule.visitAt);
    
    // 첫 번째 아이템이 아니면 선으로 연결
    final isNotFirstItem = index > 0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽: 시간 및 연결선
        SizedBox(
          width: 60,
          child: Column(
            children: [
              // 연결선 (첫 번째 아이템이 아닌 경우)
              if (isNotFirstItem)
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              
              // 시간 원
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              // 아래 연결선
              if (index < schedules.length - 1)
                Container(
                  width: 2,
                  height: 50,
                  color: AppColors.primary.withOpacity(0.3),
                ),
            ],
          ),
        ),
        
        // 오른쪽: 일정 내용
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 장소 이름
                Text(
                  schedule.placeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 메모 (있는 경우)
                if (schedule.notes != null && schedule.notes!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      schedule.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // 하단 액션 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 편집 버튼
                    TextButton.icon(
                      onPressed: () {
                        // 편집 기능 (추후 구현)
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.mediumGray,
                      ),
                      label: Text(
                        '수정',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                    
                    // 삭제 버튼
                    TextButton.icon(
                      onPressed: () {
                        // 삭제 기능 (추후 구현)
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}