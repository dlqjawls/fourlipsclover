import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_location.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';

class MatchingCreateHashtagScreen extends StatefulWidget {
  const MatchingCreateHashtagScreen({Key? key}) : super(key: key);

  @override
  State<MatchingCreateHashtagScreen> createState() =>
      _MatchingCreateHashtagScreenState();
}

class _MatchingCreateHashtagScreenState
    extends State<MatchingCreateHashtagScreen> {
  final List<String> allHashtags = [
    '한식',
    '양식',
    '중식',
    '일식',
    '분위기',
    '가성비',
    '혼밥',
    '데이트',
    '단체',
    '술맛집',
    '디저트',
    '카페',
    '브런치',
    '비건',
    '매운맛',
  ];

  final Set<String> selectedHashtags = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '선호하는 맛집 스타일'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(0.3),

          Padding(
            padding: MatchingStyles.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('어떤 맛집을 좋아하시나요?', style: MatchingStyles.titleStyle),
                SizedBox(height: 8),
                Text('최대 3개까지 선택해주세요', style: MatchingStyles.subtitleStyle),
              ],
            ),
          ),

          // Selected tags preview
          if (selectedHashtags.isNotEmpty)
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    selectedHashtags
                        .map(
                          (tag) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(tag),
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              labelStyle: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              onDeleted: () {
                                setState(() {
                                  selectedHashtags.remove(tag);
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

          // Hashtag Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: allHashtags.length,
                itemBuilder: (context, index) {
                  final hashtag = allHashtags[index];
                  final isSelected = selectedHashtags.contains(hashtag);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedHashtags.remove(hashtag);
                          } else if (selectedHashtags.length < 3) {
                            selectedHashtags.add(hashtag);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(25), // 버튼과 동일한 radius
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
                          borderRadius: BorderRadius.circular(25),
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
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                getIconForHashtag(hashtag),
                                size: 16,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.darkGray,
                              ),
                              SizedBox(width: 4),
                              Text(
                                hashtag,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.darkGray,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
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
                  selectedHashtags.isNotEmpty
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchingLocationScreen(),
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

  IconData getIconForHashtag(String hashtag) {
    switch (hashtag) {
      case '한식':
        return Icons.rice_bowl;
      case '양식':
        return Icons.restaurant;
      case '중식':
        return Icons.ramen_dining;
      case '일식':
        return Icons.set_meal;
      case '분위기':
        return Icons.mood;
      case '가성비':
        return Icons.attach_money;
      case '혼밥':
        return Icons.person;
      case '데이트':
        return Icons.favorite;
      case '단체':
        return Icons.groups;
      case '술맛집':
        return Icons.wine_bar;
      case '디저트':
        return Icons.cake;
      case '카페':
        return Icons.coffee;
      case '브런치':
        return Icons.brunch_dining;
      case '비건':
        return Icons.eco;
      case '매운맛':
        return Icons.whatshot;
      default:
        return Icons.local_dining;
    }
  }
}
