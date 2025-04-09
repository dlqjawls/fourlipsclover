import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../../models/plan/plan_list_model.dart';
import '../../../../providers/plan_provider.dart';
import '../../../../config/theme.dart';

class GroupCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final int groupId;
  final Function(DateTime, DateTime) onDaySelected;
  final List<PlanList> Function(DateTime) eventLoader;
  final Function(DateTime) onFocusedDayChanged;

  const GroupCalendar({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.groupId,
    required this.onDaySelected,
    required this.eventLoader,
    required this.onFocusedDayChanged,
  }) : super(key: key);

  @override
  State<GroupCalendar> createState() => _GroupCalendarState();
}

class _GroupCalendarState extends State<GroupCalendar> {
  // 달력 보기 모드 (월간만 유지)
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;

  // 날짜별 이벤트 캐시
  Map<DateTime, List<PlanList>> _eventsCache = {};
  bool _isLoadingEvents = false;
  bool _isChangingMonth = false; // 월 변경 중 상태 추가

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;

    // 포스트 프레임 콜백으로 이벤트 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForMonth(_focusedDay);
      // 다음 달과 이전 달 미리 로드
      _preloadAdjacentMonths(_focusedDay);
    });
  }

  // 특정 월의 이벤트를 로드하는 메서드
  Future<void> _loadEventsForMonth(DateTime month) async {
    if (!mounted) return;
    if (_isLoadingEvents &&
        month.month == _focusedDay.month &&
        month.year == _focusedDay.year)
      return;

    try {
      final planProvider = Provider.of<PlanProvider>(context, listen: false);

      // 로딩 상태 확인 - 현재 보고 있는 달만 로딩 상태 표시
      if (month.month == _focusedDay.month && month.year == _focusedDay.year) {
        setState(() {
          _isLoadingEvents = true;
        });
      }

      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      for (int i = 0; i <= lastDay.day - firstDay.day; i++) {
        final day = DateTime(month.year, month.month, i + 1);
        final normalized = DateTime(day.year, day.month, day.day);

        // 이미 캐시에 있는 날짜는 건너뛰기
        if (_eventsCache.containsKey(normalized)) continue;

        try {
          final events = await planProvider.getPlansForDate(
            widget.groupId,
            day,
          );

          if (mounted) {
            // 일괄 업데이트를 위해 setState 없이 캐시만 업데이트
            _eventsCache[normalized] = events;
          }
        } catch (e) {
          debugPrint('이벤트 로드 중 오류 발생: $e');
        }
      }

      // 모든 날짜 로드 후 한 번만 setState 호출
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      debugPrint('전체 이벤트 로드 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    }
  }

  // 인접한 달(이전 달, 다음 달) 미리 로드
  Future<void> _preloadAdjacentMonths(DateTime month) async {
    // 현재 보고 있는 달 기준 이전 달과 다음 달
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    // 백그라운드에서 로드 (UI 블로킹 없이)
    Future.microtask(() async {
      await _loadEventsForMonth(prevMonth); // 이전 달 로드
      if (mounted) {
        await _loadEventsForMonth(nextMonth); // 다음 달 로드
      }
    });
  }

  @override
  void didUpdateWidget(GroupCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      _eventsCache.clear();
      _loadEventsForMonth(_focusedDay);
      _preloadAdjacentMonths(_focusedDay);
    }
  }

  // 동기식 이벤트 로더 메서드
  List<PlanList> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsCache[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 달력 헤더 액션 버튼 추가
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 얇은 화살표와 오늘 텍스트를 둥근 테두리로 감싼 버튼
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkGray),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    final today = DateTime.now();
                    setState(() {
                      _focusedDay = today;
                      _isChangingMonth = true; // 월 변경 중 상태 설정
                    });
                    widget.onFocusedDayChanged(today);

                    // 지연 후 데이터 로드 (애니메이션 완료 후)
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        _loadEventsForMonth(today);
                        setState(() {
                          _isChangingMonth = false; // 상태 복원
                        });
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 5.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 14,
                          color: AppColors.darkGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '오늘',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 달력 위젯
        Expanded(
          child:
              _isLoadingEvents && _eventsCache.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    // 여기를 null로 해서 선택된 날짜 표시 안함
                    selectedDayPredicate: (day) => false,
                    calendarFormat: _calendarFormat, // 달력 보기 모드 설정
                    locale: 'ko_KR',
                    daysOfWeekHeight: 24,
                    rowHeight: 45,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      // 오늘 날짜 스타일
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 0, // 점 마커 숨기기
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    eventLoader: _getEventsForDay,
                    onDaySelected: widget.onDaySelected,
                    onHeaderTapped: (focusedDay) {
                      _showCompactMonthYearPicker(context, focusedDay);
                    },
                    onPageChanged: (focusedDay) {
                      // 상태 업데이트 (즉시 UI 반영)
                      setState(() {
                        _focusedDay = focusedDay;
                        _isChangingMonth = true; // 월 변경 중임을 표시
                      });
                      widget.onFocusedDayChanged(focusedDay);

                      // 월 변경 애니메이션이 끝난 후 데이터 로드 (UI 렉 방지)
                      Future.delayed(Duration(milliseconds: 300), () {
                        if (mounted) {
                          _loadEventsForMonth(focusedDay);
                          _preloadAdjacentMonths(focusedDay);
                          setState(() {
                            _isChangingMonth = false; // 상태 복원
                          });
                        }
                      });
                    },

                    // 날짜 셀 커스터마이징
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        // 여행 계획에 속하는지 확인
                        Widget? planCell = _buildCellWithPlanCheck(
                          context,
                          day,
                          _getEventsForDay(day),
                          false,
                          false,
                        );
                        if (planCell != null) {
                          return planCell;
                        }

                        // 계획에 속하지 않는 경우 기본 셀 직접 구현
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        // 오늘 날짜이면서 여행 계획에 속하는지 확인
                        return _buildCellWithPlanCheck(
                          context,
                          day,
                          _getEventsForDay(day),
                          true,
                          false,
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  // _buildCellWithPlanCheck 메서드 수정:
  Widget _buildCellWithPlanCheck(
    BuildContext context,
    DateTime day,
    List<PlanList> plans,
    bool isToday,
    bool isSelected,
  ) {
    // 오늘 날짜
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day); // 오늘 날짜 정규화

    // 이 날짜가 어떤 계획에 속하는지 확인
    PlanList? planForDay;
    bool isStartDay = false;
    bool isEndDay = false;
    bool isCompletedTrip = false; // 완료된 여행 여부

    // 날짜가 여러 계획에 속할 수 있으므로, 우선순위를 정해 처리
    // 1. 진행 중인 여행 > 2. 예정된 여행 > 3. 완료된 여행
    PlanList? ongoingPlan;
    PlanList? upcomingPlan;
    PlanList? completedPlan;

    for (var plan in plans) {
      // 여행의 시작일과 종료일 정규화 (시간 제외)
      final planStartDate = DateTime(
        plan.startDate.year,
        plan.startDate.month,
        plan.startDate.day,
      );
      final planEndDate = DateTime(
        plan.endDate.year,
        plan.endDate.month,
        plan.endDate.day,
      );

      // 여행 상태 확인 - 종료일이 오늘보다 이전인 경우만 완료된 여행으로 처리
      // 오늘이 종료일인 경우는 여전히 진행 중인 여행으로 간주
      final bool isPlanCompleted = planEndDate.isBefore(todayDate);

      // 이 날짜가 여행에 속하는지 확인
      bool belongsToTrip = false;
      bool isStart = false;
      bool isEnd = false;

      if (isSameDay(day, plan.startDate)) {
        belongsToTrip = true;
        isStart = true;
      } else if (isSameDay(day, plan.endDate)) {
        belongsToTrip = true;
        isEnd = true;
      } else if (day.isAfter(plan.startDate) && day.isBefore(plan.endDate)) {
        belongsToTrip = true;
      }

      if (belongsToTrip) {
        if (isPlanCompleted) {
          completedPlan = plan;
          if (isStart) isStartDay = true;
          if (isEnd) isEndDay = true;
        } else if ((planStartDate.isBefore(todayDate) ||
                isSameDay(planStartDate, todayDate)) &&
            (planEndDate.isAfter(todayDate) ||
                isSameDay(planEndDate, todayDate))) {
          // 진행 중인 여행 - 최우선
          // 오늘이 시작일이거나 종료일인 경우도 포함
          ongoingPlan = plan;
          if (isStart) isStartDay = true;
          if (isEnd) isEndDay = true;
          break; // 진행 중인 여행을 찾으면 반복 중단
        } else {
          // 예정된 여행
          upcomingPlan = plan;
          if (isStart) isStartDay = true;
          if (isEnd) isEndDay = true;
        }
      }
    }

    // 우선순위에 따라 표시할 여행 선택
    if (ongoingPlan != null) {
      planForDay = ongoingPlan;
      isCompletedTrip = false;
    } else if (upcomingPlan != null) {
      planForDay = upcomingPlan;
      isCompletedTrip = false;
    } else if (completedPlan != null) {
      planForDay = completedPlan;
      isCompletedTrip = true;
    }

    // 계획에 속하지 않으면
    if (planForDay == null) {
      if (isToday) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            width: 32,
            height: 32,
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
      // null 대신 일반 날짜용 위젯 반환
      return Center(
        child: Text('${day.day}', style: const TextStyle(color: Colors.black)),
      );
    }

    // 계획에 속하면 범위 표시 셀 반환
    // 완료된 여행은 회색, 진행 중이거나 예정된 여행은 primary 색상으로 표시
    Color fillColor =
        isCompletedTrip
            ? Colors.grey.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.2);

    Color borderColor =
        isCompletedTrip ? Colors.grey.withOpacity(0.5) : AppColors.primary;

    return _buildRangeCell(
      day,
      fillColor,
      borderColor,
      isStartDay,
      isEndDay,
      isToday: isToday,
    );
  }

  // 범위 셀 생성 함수 - 글씨 강조 스타일 수정
  Widget _buildRangeCell(
    DateTime day,
    Color fillColor,
    Color borderColor,
    bool isStart,
    bool isEnd, {
    bool isToday = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: fillColor,
        // 테두리 추가 - 시작일과 종료일에 맞게 선택적으로 적용
        border: Border(
          left:
              isStart
                  ? BorderSide(color: borderColor, width: 1.5)
                  : BorderSide.none,
          top: BorderSide(color: borderColor, width: 1.5),
          right:
              isEnd
                  ? BorderSide(color: borderColor, width: 1.5)
                  : BorderSide.none,
          bottom: BorderSide(color: borderColor, width: 1.5),
        ),
        // 시작일 왼쪽만 둥글게, 종료일 오른쪽만 둥글게
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isStart ? 100 : 0),
          right: Radius.circular(isEnd ? 100 : 0),
        ),
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppColors.primaryLight : Colors.transparent,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black,
                // 글씨체 강조 제거 - 모든 날짜 동일한 폰트 두께 사용
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCompactMonthYearPicker(BuildContext context, DateTime currentDate) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 80,
              vertical: 200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CompactDatePicker(
              initialDate: currentDate,
              firstDate: DateTime(2023),
              lastDate: DateTime(2030),
              onDateSelected: (newDate) {
                setState(() {
                  _focusedDay = newDate;
                  _isChangingMonth = true;
                });
                widget.onFocusedDayChanged(newDate);

                // 지연 후 데이터 로드
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    _loadEventsForMonth(newDate);
                    _preloadAdjacentMonths(newDate);
                    setState(() {
                      _isChangingMonth = false;
                    });
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ),
    );
  }
}

// CompactDatePicker 클래스는 변경 없음
class CompactDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const CompactDatePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CompactDatePicker> createState() => _CompactDatePickerState();
}

class _CompactDatePickerState extends State<CompactDatePicker> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '날짜 선택',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          // 년도와 월 선택 컨테이너
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 년도 컬럼
              Column(
                children: [
                  // 년도 선택 박스
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        isExpanded: true,
                        isDense: true,
                        itemHeight: 48,
                        items: List.generate(
                          widget.lastDate.year - widget.firstDate.year + 1,
                          (index) => DropdownMenuItem(
                            value: widget.firstDate.year + index,
                            child: Text(
                              '${widget.firstDate.year + index}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (year) {
                          if (year != null) {
                            setState(() {
                              _selectedYear = year;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  // 년도 라벨
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '년',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              // 중간 구분자
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              // 월 컬럼
              Column(
                children: [
                  // 월 선택 박스
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        isExpanded: true,
                        isDense: true,
                        itemHeight: 48,
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (month) {
                          if (month != null) {
                            setState(() {
                              _selectedMonth = month;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  // 월 라벨
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '월',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  widget.onDateSelected(
                    DateTime(_selectedYear, _selectedMonth, 1),
                  );
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
