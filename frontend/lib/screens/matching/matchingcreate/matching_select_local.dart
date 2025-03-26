import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_resist.dart';

class MatchingSelectLocalScreen extends StatefulWidget {
  const MatchingSelectLocalScreen({Key? key}) : super(key: key);

  @override
  State<MatchingSelectLocalScreen> createState() =>
      _MatchingSelectLocalScreenState();
}

class _MatchingSelectLocalScreenState extends State<MatchingSelectLocalScreen> {
  String _selectedFilter = '전체';
  String? _selectedSort;

  // 임시 데이터 (가이드 목록)
  final List<Map<String, dynamic>> guideList = [
    {
      'name': '골든클로버',
      'imageAsset': Icons.account_circle,
      'iconColor': Colors.amber,
      'hashtags': ['#반주사랑', '#먹고죽자', '#아재입맛'],
      'rating': 4.8,
      'reviews': 123,
    },
    {
      'name': '싱그러운 클로버',
      'imageAsset': Icons.account_circle,
      'iconColor': AppColors.primary,
      'hashtags': ['#맛집투어', '#미식가', '#맛도리'],
      'rating': 4.5,
      'reviews': 98,
    },
    {
      'name': '초록 클로버',
      'imageAsset': Icons.account_circle,
      'iconColor': AppColors.primaryDark,
      'hashtags': ['#맛집탐방', '#인싸맛집', '#힙플레이스'],
      'rating': 4.7,
      'reviews': 156,
    },
    {
      'name': '행운 가득 클로버',
      'imageAsset': Icons.account_circle,
      'iconColor': AppColors.primaryLight,
      'hashtags': ['#미식여행', '#맛집추천', '#푸드로그'],
      'rating': 4.6,
      'reviews': 87,
    },
  ];

  void _showConfirmationDialog(Map<String, dynamic> selectedGuide) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('가이드 선택', style: MatchingStyles.dialogTitleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: selectedGuide['iconColor'],
                radius: 30,
                child: Icon(
                  selectedGuide['imageAsset'],
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '${selectedGuide['name']}님과 함께',
                style: MatchingStyles.dialogContentStyle,
              ),
              Text(
                '맛집 탐방을 떠나시겠습니까?',
                style: MatchingStyles.dialogContentBoldStyle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 모달 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MatchingResistScreen(guide: selectedGuide),
                  ),
                );
              },
              style: MatchingStyles.dialogButtonStyle,
              child: Text('확인', style: MatchingStyles.dialogButtonTextStyle),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '가이드 선택'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(0.9),

          // Title Section
          Padding(
            padding: MatchingStyles.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('나를 위한 가이드님을 선택해주세요.', style: MatchingStyles.titleStyle),
                SizedBox(height: 8),
                Text(
                  '선택한 지역의 맛집 전문 가이드님들이에요!',
                  style: MatchingStyles.subtitleStyle,
                ),
              ],
            ),
          ),

          // 필터 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Wrap(
                  spacing: 8,
                  children:
                      ['전체', '인기', '신규'].map((filter) {
                        return FilterChip(
                          selected: _selectedFilter == filter,
                          label: Text(filter),
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color:
                                _selectedFilter == filter
                                    ? AppColors.primary
                                    : AppColors.darkGray,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color:
                                  _selectedFilter == filter
                                      ? AppColors.primary
                                      : AppColors.lightGray,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: _selectedSort,
                  hint: Text('정렬'),
                  items:
                      <String>['평점순', '리뷰순', '최신순'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSort = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // 가이드 리스트
          Expanded(
            child: ListView.builder(
              itemCount: guideList.length,
              itemBuilder: (context, index) {
                final guide = guideList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Material(
                    type: MaterialType.transparency, // splash 효과 제거
                    child: InkWell(
                      splashFactory: NoSplash.splashFactory, // splash 효과 제거
                      highlightColor: Colors.transparent, // 하이라이트 효과 제거
                      onTap: () => _showConfirmationDialog(guide),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 프로필 이미지
                              CircleAvatar(
                                backgroundColor: guide['iconColor'],
                                radius: 25,
                                child: Icon(
                                  guide['imageAsset'],
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 16),
                              // 정보 영역
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          guide['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            Text(
                                              '${guide['rating']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.darkGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      (guide['hashtags'] as List).join(' '),
                                      style: TextStyle(
                                        color: AppColors.mediumGray,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${guide['reviews']}개의 리뷰',
                                      style: TextStyle(
                                        color: AppColors.mediumGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 선택 아이콘
                              Icon(
                                Icons.navigate_next,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
