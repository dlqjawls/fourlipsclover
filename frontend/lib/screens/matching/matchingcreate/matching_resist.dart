import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/screens/matching/matchingcreate/widgets/matching_submit_buttons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MatchingResistScreen extends StatefulWidget {
  final Map<String, dynamic> guide;
  const MatchingResistScreen({Key? key, required this.guide}) : super(key: key);

  @override
  State<MatchingResistScreen> createState() => _MatchingResistScreenState();
}

class _MatchingResistScreenState extends State<MatchingResistScreen> {
  // 그룹 관련 변수
  List<Group> _groups = [];
  Group? _selectedGroupObj;

  // 드롭다운 선택값 변수
  String? _selectedGroup;
  String? _selectedTransport;
  String? _selectedFoodCategory;
  String? _selectedTaste;

  // 선택된 시작일 / 종료일
  DateTime? _startDate;
  DateTime? _endDate;

  // TableCalendar에서 사용할 focusedDay
  late DateTime _focusedDay;

  // 텍스트필드 컨트롤러 및 포커스노드
  final TextEditingController _requestController = TextEditingController();
  final FocusNode _requestFocusNode = FocusNode();

  // 그룹 드롭다운 목록
  List<String> get _groupItems {
    List<String> items = ['나혼자 산다'];
    if (_groups.isNotEmpty) {
      items.addAll(_groups.map((group) => group.name));
    }
    return items;
  }

  final List<String> _transportItems = ['도보', '택시/버스', '렌터카', '기타'];
  final List<String> _foodCategoryItems = ['한식', '중식', '일식', '양식', '기타'];
  final List<String> _tasteItems = ['맵게하게', '달콤하게', '짭짤하게', '담백하게', '기타'];

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _focusedDay = DateTime.now();
  }

  Future<void> _loadGroups() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.fetchMyGroups();
    setState(() {
      _groups = groupProvider.groups;
    });
  }

  @override
  void dispose() {
    _requestController.dispose();
    _requestFocusNode.dispose();
    super.dispose();
  }

  /// TableCalendar를 활용한 범위 선택 다이얼로그 (StatefulBuilder 사용)
  Future<void> _showRangeCalendarDialog(BuildContext context) async {
    // 다이얼로그 열릴 때 기존 선택값 유지
    DateTime? rangeStart = _startDate;
    DateTime? rangeEnd = _endDate;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            String rangeText = '';
            if (rangeStart != null && rangeEnd != null) {
              rangeText =
                  '${DateFormat("yyyy.MM.dd").format(rangeStart!)} ~ ${DateFormat("yyyy.MM.dd").format(rangeEnd!)}';
            }
            return AlertDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '여행 일정 선택',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (rangeStart != null && rangeEnd != null)
                    Text(
                      rangeText,
                      style: TextStyle(fontSize: 14, color: AppColors.darkGray),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2026, 12, 31),
                  focusedDay: _focusedDay,
                  locale: 'ko_KR',
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  // null인 경우 _focusedDay를 기본값으로 전달
                  rangeStartDay: rangeStart ?? _focusedDay,
                  rangeEndDay: rangeEnd ?? _focusedDay,
                  onRangeSelected: (start, end, focusedDay) {
                    setStateDialog(() {
                      rangeStart = start;
                      rangeEnd = end;
                      _focusedDay = focusedDay;
                    });
                  },
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
                    // 오늘 날짜는 부드러운 테두리와 색상으로 표시
                    todayDecoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    // 범위 시작/종료는 진한 색상으로, 자연스러운 원형 모양
                    rangeStartDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    // 범위 내부는 부드럽게 채워지도록
                    rangeHighlightColor: AppColors.primaryLight,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    if (rangeStart != null && rangeEnd != null) {
                      setState(() {
                        _startDate = rangeStart;
                        _endDate = rangeEnd;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 센스있는 날짜 범위 선택 카드 위젯 (여행 일정)
  Widget _buildStyledDateRangeDisplay() {
    return InkWell(
      onTap: () => _showRangeCalendarDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child:
                  _startDate != null && _endDate != null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '여행 기간',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat("yyyy.MM.dd").format(_startDate!)} - ${DateFormat("yyyy.MM.dd").format(_endDate!)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        '여행 날짜를 선택해주세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mediumGray,
                        ),
                      ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 빈 공간 터치 시 키보드 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: MatchingStyles.buildAppBar(context, '가이드 신청서'),
        body: Column(
          children: [
            MatchingStyles.buildProgressIndicator(1.0),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 가이드 프로필 카드
                      _buildGuideProfileCard(),
                      const SizedBox(height: 20),
                      // 여행 일정 카드 (최상단에 단독으로 배치)
                      _buildStyledDateRangeDisplay(),
                      const SizedBox(height: 20),
                      // 기본 정보 섹션
                      _buildSectionBox(
                        title: '기본 정보',
                        icon: Icons.person_outline,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  '그룹 선택',
                                  _groupItems,
                                  _selectedGroup,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  '이동 수단',
                                  _transportItems,
                                  _selectedTransport,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // 음식 선호도 섹션
                      _buildSectionBox(
                        title: '음식 선호도',
                        icon: Icons.restaurant_menu,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  '음식 종류',
                                  _foodCategoryItems,
                                  _selectedFoodCategory,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  '선호하는 맛',
                                  _tasteItems,
                                  _selectedTaste,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // 요청사항 섹션
                      _buildSectionBox(
                        title: '요청사항',
                        icon: Icons.edit_note,
                        children: [
                          Text(
                            '식사 예산, 알레르기, 선호 분위기, 하루 식사 횟수, 못 먹는 음식, 웨이팅 수용도 등',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.verylightGray,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _requestController,
                              focusNode: _requestFocusNode,
                              maxLines: 5,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                                hintText: '여행 요청사항을 자유롭게 적어주세요',
                                hintStyle: TextStyle(
                                  color: AppColors.mediumGray,
                                ),
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
            // 하단 버튼 영역
            MatchingSubmitButtons(
              selectedGroup: _selectedGroupObj,
              selectedTransport: _selectedTransport,
              selectedFoodCategory: _selectedFoodCategory,
              selectedTaste: _selectedTaste,
              request: _requestController.text,
              requestController: _requestController,
              guide: widget.guide,
              regionId: widget.guide['regionId'],
              tagIds: widget.guide['tagIds'],
              startDate:
                  _startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : null,
              endDate:
                  _endDate != null
                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                      : null,
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // 가이드 프로필 카드 위젯
  Widget _buildGuideProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Hero(
            tag: 'guide_${widget.guide['name']}',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child:
                    widget.guide['profileUrl'].isEmpty
                        ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                        : Image.network(
                          widget.guide['profileUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            );
                          },
                        ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.guide['name']}님과 함께하는',
                  style: TextStyle(color: AppColors.darkGray, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '맛있는 여행',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 박스 위젯 (기본 정보, 음식 선호도, 요청사항 등)
  Widget _buildSectionBox({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 내용 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // 드롭다운 위젯
  Widget _buildDropdown(String label, List<String> items, String? value) {
    return InkWell(
      onTap: () => _showDropdownDialog(label, items, value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.verylightGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? '선택하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          value != null
                              ? AppColors.darkGray
                              : AppColors.mediumGray,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 드롭다운 선택 다이얼로그
  void _showDropdownDialog(
    String label,
    List<String> items,
    String? currentValue,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 다이얼로그 타이틀
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.lightGray, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // 항목 목록
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == currentValue;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          switch (label) {
                            case '그룹 선택':
                              _selectedGroup = item;
                              if (item == '나혼자 산다') {
                                _selectedGroupObj = Group(
                                  groupId: 0,
                                  name: '나혼자 산다',
                                  isPublic: true,
                                  description: '개인 사용자',
                                  memberId: 0,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );
                              } else {
                                _selectedGroupObj = _groups.firstWhere(
                                  (group) => group.name == item,
                                  orElse:
                                      () => Group(
                                        groupId: -1,
                                        name: item,
                                        isPublic: true,
                                        description: '',
                                        memberId: -1,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      ),
                                );
                              }
                              break;
                            case '이동 수단':
                              _selectedTransport = item;
                              break;
                            case '음식 종류':
                              _selectedFoodCategory = item;
                              break;
                            case '선호하는 맛':
                              _selectedTaste = item;
                              break;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.lightGray,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.darkGray,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
