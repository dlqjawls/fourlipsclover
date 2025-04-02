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

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('종료일은 시작일 이후여야 합니다.')));
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  // 드롭다운 섹션 빌드
  Widget _buildDropdownSection(
    String title,
    Icon icon,
    List<Widget> dropdowns,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: dropdowns[0]),
              const SizedBox(width: 16),
              Expanded(child: dropdowns[1]),
            ],
          ),
        ],
      ),
    );
  }

  // 드롭다운 아이템 빌드
  Widget _buildDropdown(String label, List<String> items, String? value) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.verylightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _showDropdownDialog(label, items, value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
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
                      fontWeight:
                          value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '가이드 신청서'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(1.0),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: MatchingStyles.defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 가이드 정보 카드
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mediumGray.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'guide_${widget.guide['name']}',
                            child: CircleAvatar(
                              backgroundColor: widget.guide['iconColor'],
                              radius: 30,
                              child: Icon(
                                widget.guide['imageAsset'],
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.guide['name']}님과 함께하는',
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 16,
                                  ),
                                ),
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
                    ),
                    const SizedBox(height: 32),

                    // 드롭다운 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDropdownSection(
                            '기본 정보',
                            Icon(
                              Icons.group,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            [
                              _buildDropdown(
                                '그룹 선택',
                                _groupItems,
                                _selectedGroup,
                              ),
                              _buildDropdown(
                                '이동 수단',
                                _transportItems,
                                _selectedTransport,
                              ),
                            ],
                          ),
                          Container(
                            height: 1,
                            color: AppColors.lightGray.withOpacity(0.3),
                          ),
                          _buildDropdownSection(
                            '음식 선호도',
                            Icon(
                              Icons.restaurant_menu,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            [
                              _buildDropdown(
                                '음식 종류',
                                _foodCategoryItems,
                                _selectedFoodCategory,
                              ),
                              _buildDropdown(
                                '선호하는 맛',
                                _tasteItems,
                                _selectedTaste,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '여행 일정',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.verylightGray,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.lightGray.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '시작일',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _startDate != null
                                              ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_startDate!)
                                              : '선택하세요',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                _startDate != null
                                                    ? AppColors.darkGray
                                                    : AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.verylightGray,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.lightGray.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '종료일',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _endDate != null
                                              ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_endDate!)
                                              : '선택하세요',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                _endDate != null
                                                    ? AppColors.darkGray
                                                    : AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 요청사항 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '요청사항',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '식사 예산, 알레르기, 선호 분위기, 하루 식사 횟수, 못 먹는 음식, 웨이팅 수용도 등',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _requestController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.verylightGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintText: '여행 요청사항을 자유롭게 적어주세요...',
                              hintStyle: TextStyle(color: AppColors.mediumGray),
                            ),
                          ),
                        ],
                      ),
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
    );
  }
}
