import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/group/group_model.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/screens/matching/matchingcreate/widgets/matching_submit_buttons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  DateTime? _startDate;
  DateTime? _endDate;
  // 텍스트필드 컨트롤러
  final TextEditingController _requestController = TextEditingController();

  // 드롭다운 목록
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

  // 키보드 포커스 해제를 위한 FocusNode
  final FocusNode _requestFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadGroups();
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

  // 날짜 선택 다이얼로그
  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primary,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: child!,
        );
      },
      saveText: '선택 완료',
      cancelText: '취소',
      confirmText: '확인',
      errorFormatText: '잘못된 형식입니다',
      errorInvalidText: '잘못된 범위입니다',
      errorInvalidRangeText: '잘못된 범위입니다',
      fieldStartHintText: '여행 시작일',
      fieldEndHintText: '여행 종료일',
      fieldStartLabelText: '여행 시작일',
      fieldEndLabelText: '여행 종료일',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // 날짜 선택 메서드 추가
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 시작일이 종료일보다 늦을 경우 종료일을 시작일로 설정
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 화면의 빈 공간을 터치하면 키보드가 내려가도록
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
                      // 가이드 프로필 카드 추가
                      _buildGuideProfileCard(),
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

                      // 여행 일정 섹션
                      _buildSectionBox(
                        title: '여행 일정',
                        icon: Icons.calendar_today,
                        children: [
                          InkWell(
                            onTap: () => _showDateRangePicker(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.verylightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '여행 기간 선택',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.darkGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (_startDate != null && _endDate != null)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDateBox(
                                            '출발',
                                            _startDate!,
                                            AppColors.primary.withOpacity(0.1),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 24,
                                          height: 2,
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildDateBox(
                                            '도착',
                                            _endDate!,
                                            AppColors.primary.withOpacity(0.05),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '여행 날짜를 선택해주세요',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
            // 하단 버튼
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

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

  // 드롭다운 다이얼로그 표시
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

  // 날짜 표시 박스 위젯
  Widget _buildDateBox(String label, DateTime date, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('M월 d일 (E)', 'ko_KR').format(date),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('yyyy년').format(date),
            style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }
}
