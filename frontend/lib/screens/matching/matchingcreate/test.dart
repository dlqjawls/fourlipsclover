import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';

class MatchingResistScreen extends StatefulWidget {
  final Map<String, dynamic> guide;
  const MatchingResistScreen({Key? key, required this.guide}) : super(key: key);

  @override
  State<MatchingResistScreen> createState() => _MatchingResistScreenState();
}

class _MatchingResistScreenState extends State<MatchingResistScreen> {
  // 드롭다운 선택값 변수
  String? _selectedGroup;
  String? _selectedTransport;
  String? _selectedFoodCategory;
  String? _selectedTaste;

  // 텍스트필드 컨트롤러
  final TextEditingController _requestController = TextEditingController();

  // 예시 드롭다운 목록
  final List<String> _groupItems = ['소규모', '중규모', '대규모'];
  final List<String> _transportItems = ['도보', '택시/버스', '렌터카', '기타'];
  final List<String> _foodCategoryItems = ['한식', '중식', '일식', '양식', '기타'];
  final List<String> _tasteItems = ['맵게', '달게', '짭짤', '담백', '기타'];

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
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
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      padding: EdgeInsets.all(20),
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
                          SizedBox(width: 16),
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
                    SizedBox(height: 32),

                    // 드롭다운 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDropdownSection(
                            '기본 정보',
                            Icon(Icons.group, color: AppColors.primary),
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
                          Divider(height: 1),
                          _buildDropdownSection(
                            '음식 선호도',
                            Icon(
                              Icons.restaurant_menu,
                              color: AppColors.primary,
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
                    SizedBox(height: 32),

                    // 요청사항 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.edit_note, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('요청사항', style: MatchingStyles.subtitleStyle),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '식사 예산, 알레르기, 선호 분위기, 하루 식사 횟수, 못 먹는 음식, 웨이팅 수용도 등',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGray,
                            ),
                          ),
                          SizedBox(height: 16),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 신청하기 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      '신청하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildDropdownSection 메서드를 수정합니다
  Widget _buildDropdownSection(
    String title,
    Icon icon,
    List<Widget> dropdowns,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 8),
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
          SizedBox(height: 16),
          // GridView 대신 Row와 Column 조합으로 변경
          Row(
            children: [
              Expanded(child: dropdowns[0]),
              SizedBox(width: 16),
              Expanded(child: dropdowns[1]),
            ],
          ),
        ],
      ),
    );
  }

  // _buildDropdown 메서드를 수정합니다
  Widget _buildDropdown(String label, List<String> items, String? value) {
    return Container(
      height: 70, // 고정 높이 설정
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.verylightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          _showDropdownDialog(label, items, value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
            SizedBox(height: 4),
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
                    overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
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
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
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
                        padding: EdgeInsets.symmetric(
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
                            Spacer(),
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
