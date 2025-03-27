import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_select_local.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';

class MatchingLocationScreen extends StatefulWidget {
  const MatchingLocationScreen({Key? key}) : super(key: key);

  @override
  State<MatchingLocationScreen> createState() => _MatchingLocationScreenState();
}

class _MatchingLocationScreenState extends State<MatchingLocationScreen> {
  final List<String> locations = [
    '서울',
    '부산',
    '대구',
    '인천',
    '광주',
    '대전',
    '울산',
    '세종',
    '경기',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '여행 지역 선택'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(0.6),

          // Description
          Padding(
            padding: MatchingStyles.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('어디로 여행을 떠나시나요?', style: MatchingStyles.titleStyle),
                SizedBox(height: 8),
                Text(
                  '맛집 탐방을 위한 지역을 선택해주세요',
                  style: MatchingStyles.subtitleStyle,
                ),
              ],
            ),
          ),

          // Location Grid
          Expanded(
            child: Padding(
              padding: MatchingStyles.defaultPadding,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final isSelected = selectedLocation == location;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedLocation = location;
                        });
                      },
                      borderRadius: BorderRadius.circular(12), // 버튼과 동일한 radius
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.lightGray,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              location,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.darkGray,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Next button
          Padding(
            padding: MatchingStyles.defaultPadding,
            child: ElevatedButton(
              onPressed:
                  selectedLocation != null
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchingSelectLocalScreen(),
                          ),
                        );
                      }
                      : null,
              style: MatchingStyles.buttonStyle,
              child: Text('다음', style: MatchingStyles.buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
