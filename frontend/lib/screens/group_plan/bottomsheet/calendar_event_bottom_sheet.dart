import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan/plan_list_model.dart';
import '../../../models/plan/plan_model.dart';
import '../../../models/plan/plan_schedule_model.dart';
import '../../../providers/plan_provider.dart';
import '../../../widgets/clover_loading_spinner.dart';
import '../plan_detail_screen.dart';

class CalendarEventBottomSheet extends StatefulWidget {
  final int groupId;
  final DateTime date;
  
  const CalendarEventBottomSheet({
    Key? key,
    required this.groupId,
    required this.date,
  }) : super(key: key);
  
  @override
  _CalendarEventBottomSheetState createState() => _CalendarEventBottomSheetState();
}

class _CalendarEventBottomSheetState extends State<CalendarEventBottomSheet> {
  List<PlanList>? _plans;
  List<PlanSchedule>? _schedules;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    
    try {
      // 1. 계획 로드
      final plans = await planProvider.getPlansForDate(widget.groupId, widget.date);
      
      // 2. 일정 로드
      final schedulesForDate = await planProvider.getSchedulesForDate(widget.groupId, widget.date);
      
      // 데이터 설정 (상태 업데이트)
      if (mounted) {
        setState(() {
          _plans = plans;
          _schedules = schedulesForDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('데이터 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _plans = [];
          _schedules = [];
          _isLoading = false;
        });
      }
    }
  }

  // 계획 상세 화면으로 이동 (상세 일정 탭 선택)
  void _navigateToPlanDetail(PlanList planList) {
    // 바텀시트 닫기
    Navigator.pop(context);
    
    // PlanList 객체를 Plan 객체로 변환
    final plan = Plan(
      planId: planList.planId,
      groupId: widget.groupId,
      treasurerId: planList.treasurerId,
      title: planList.title,
      description: planList.description,
      startDate: planList.startDate,
      endDate: planList.endDate,
      createdAt: planList.createdAt,
      updatedAt: null, // PlanList에 없는 필드는 null로 설정
    );
    
    // 계획 상세 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(
          plan: plan,
          groupId: widget.groupId,
          initialTabIndex: 1, // 상세 일정 탭(인덱스 1) 선택
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 날짜 표시
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 날짜 텍스트
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(widget.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // 새로고침 버튼
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          
          // 로딩 스피너 또는 이벤트 목록
          _isLoading
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: CloverLoadingSpinner(size: 40),
              )
            : Expanded(
                child: (_schedules?.isEmpty ?? true) 
                  ? _buildEmptyState(_plans ?? [])
                  : _buildEventList(_schedules!),
              ),
          
          // 하단 버튼 영역 - 계획이 있을 때만 표시
          if (_plans?.isNotEmpty ?? false)
            _buildBottomButton(),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(List<PlanList> plans) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이미지 또는 아이콘
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          
          // 안내 메시지
          Text(
            plans.isEmpty 
              ? '이 날짜에 계획된 여행이 없어요' 
              : '세부 일정이 없어요',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (plans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '아래 버튼을 눌러 일정을 확인해보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEventList(List<PlanSchedule> schedules) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }
  
  Widget _buildScheduleCard(PlanSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 일정 상세 보기 또는 편집 화면으로 이동할 수 있습니다
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 시간 표시
              Container(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(schedule.visitAt),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 세로 구분선
              Container(
                width: 1,
                height: 40,
                color: AppColors.lightGray,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              
              // 장소 및 메모 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 장소명
                    Text(
                      schedule.placeName ?? "알수없는 장소",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // 메모가 있으면 표시
                    if (schedule.notes != null && schedule.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          schedule.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              
              // 오른쪽 화살표 아이콘
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomButton() {
    // 여러 계획이 있을 경우 선택 가능
    if ((_plans?.length ?? 0) > 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
            
            // 계획 선택 드롭다운 버튼
            DropdownButtonFormField<PlanList>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.lightGray),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: "상세 일정을 확인할 계획 선택",
                hintStyle: TextStyle(color: AppColors.mediumGray),
              ),
              items: _plans!.map((plan) => DropdownMenuItem<PlanList>(
                value: plan,
                child: Text(plan.title),
              )).toList(),
              onChanged: (plan) {
                if (plan != null) {
                  _navigateToPlanDetail(plan);
                }
              },
              icon: Icon(Icons.calendar_month, color: AppColors.primary),
            ),
          ],
        ),
      );
    }
    
    // 하나의 계획만 있는 경우 바로 일정 추가 버튼 표시
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _plans!.isNotEmpty ? () => _navigateToPlanDetail(_plans!.first) : null,
        icon: const Icon(Icons.calendar_month, size: 20),
        label: const Text(
          '상세 일정 확인하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}