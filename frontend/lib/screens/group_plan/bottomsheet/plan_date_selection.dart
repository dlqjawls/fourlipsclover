import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/theme.dart';

class PlanDateSelection extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime focusedDay;
  final Function(DateTime?, DateTime?, DateTime) onDatesSelected;

  const PlanDateSelection({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.focusedDay,
    required this.onDatesSelected,
  }) : super(key: key);

  @override
  State<PlanDateSelection> createState() => _PlanDateSelectionState();
}

class _PlanDateSelectionState extends State<PlanDateSelection> {
  late DateTime _focusedDay;
  DateTime? _startDate;
  DateTime? _endDate;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.enforced;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 메시지 또는 선택된 날짜 표시
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('yyyy년 MM월 dd일').format(_startDate!)} - ${DateFormat('yyyy년 MM월 dd일').format(_endDate!)}'
                        : '여행 시작일과 종료일을 선택해주세요.',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 달력 위젯
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,

            // 날짜 범위 선택 설정
            selectedDayPredicate: (day) {
              return isSameDay(_startDate, day);
            },
            rangeStartDay: _startDate,
            rangeEndDay: _endDate,
            rangeSelectionMode: _rangeSelectionMode,

            // 달력 설정
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),

            // 날짜 선택 콜백
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _startDate = selectedDay;
                _endDate = selectedDay;
                _focusedDay = focusedDay;
                _rangeSelectionMode = RangeSelectionMode.enforced;
              });
              widget.onDatesSelected(_startDate, _endDate, _focusedDay);
            },

            // 날짜 범위 선택 콜백
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _startDate = start;
                _endDate = end;
                _focusedDay = focusedDay;
              });
              widget.onDatesSelected(_startDate, _endDate, _focusedDay);
            },

            // 페이지 변경 콜백
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            // 달력 스타일
            calendarStyle: CalendarStyle(
              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              // 선택된 날짜 스타일
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              // 범위 시작일 스타일
              rangeStartDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              // 범위 종료일 스타일
              rangeEndDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              // 범위 내 날짜 스타일
              withinRangeTextStyle: TextStyle(color: AppColors.darkGray),
              rangeHighlightColor: AppColors.primary.withOpacity(0.2),
            ),

            // 요일 스타일
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

            // 로케일 설정
            locale: 'ko_KR',
          ),
        ],
      ),
    );
  }
}