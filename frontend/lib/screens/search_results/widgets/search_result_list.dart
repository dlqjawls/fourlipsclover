// search_result_list.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart'; // 테마 색상 적용하기 위한 import

class SearchResultList extends StatefulWidget {
  final String query;
  final String? filter;

  const SearchResultList({Key? key, required this.query, this.filter})
    : super(key: key);

  @override
  State<SearchResultList> createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  final ScrollController _scrollController = ScrollController();
  final int _initialItemCount = 5; // 초기에 보여줄 아이템 수
  final int _loadMoreCount = 15; // 추가로 보여줄 아이템 수
  int _displayCount = 5; // 현재 보여주는 아이템 수
  bool _isAllLoaded = false; // 모든 데이터가 로드되었는지 여부
  bool _isLoading = false; // 로딩 중인지 여부
  late List<Map<String, dynamic>> _filteredRestaurants;

  @override
  void initState() {
    super.initState();
    _displayCount = _initialItemCount;
    _scrollController.addListener(_scrollListener);

    // 위젯이 화면에서 제거되었다가 다시 표시될 때마다 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // didChangeAppLifecycleState나 route 변경을 감지하는 방법도 고려할 수 있습니다
      _displayCount = _initialItemCount;
      _isAllLoaded = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 스크롤이 맨 아래에 도달했을 때 추가 데이터 로드
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (!_isAllLoaded && !_isLoading) {
      setState(() {
        _isLoading = true; // 로딩 시작
      });

      // 1초 후에 데이터 로드 (로딩 시간 추가)
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _displayCount = _displayCount + _loadMoreCount;
            if (_displayCount >= _filteredRestaurants.length) {
              _displayCount = _filteredRestaurants.length;
              _isAllLoaded = true;
            }
            _isLoading = false; // 로딩 완료
          });
        }
      });
    }
  }

  // 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (실제로는 API에서 가져올 것)
    final restaurants = [
      {
        "id": 1,
        "name": "스시타케 광주점",
        "score": 93,
        "address": "광주 광산구 임방울대로 852",
        "distance": "2.0km",
        "tags": ["초밥", "사시미"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 218,
      },
      {
        "id": 2,
        "name": "교다이쇼쿠도 수완점",
        "score": 91,
        "address": "광주 광산구 장신로 95",
        "distance": "2.3km",
        "tags": ["일식", "돈까스"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 176,
      },
      {
        "id": 3,
        "name": "코너스톤 키친",
        "score": 90,
        "address": "광주 광산구 장신로 82",
        "distance": "1.5km",
        "tags": ["브런치", "파스타"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 156,
      },
      {
        "id": 4,
        "name": "쉐프의 부엌",
        "score": 89,
        "address": "광주 광산구 임방울대로 840",
        "distance": "2.5km",
        "tags": ["양식", "스테이크"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 142,
      },
      {
        "id": 5,
        "name": "블루밍가든",
        "score": 86,
        "address": "광주 광산구 장신로 110",
        "distance": "2.1km",
        "tags": ["브런치", "아메리칸"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 128,
      },
      {
        "id": 6,
        "name": "금바다 해물탕",
        "score": 85,
        "address": "광주 광산구 임방울대로 778",
        "distance": "2.2km",
        "tags": ["해물탕", "해물찜"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 115,
      },
      {
        "id": 7,
        "name": "비스트로 담길",
        "score": 82,
        "address": "광주 광산구 임방울대로 825-35",
        "distance": "1.6km",
        "tags": ["브런치", "샐러드"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 108,
      },
      {
        "id": 8,
        "name": "더키친 수완점",
        "score": 81,
        "address": "광주 광산구 임방울대로 830",
        "distance": "1.9km",
        "tags": ["퓨전음식", "파스타"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 96,
      },
      {
        "id": 9,
        "name": "쟁반집 수완점",
        "score": 79,
        "address": "광주 광산구 임방울대로 850",
        "distance": "1.7km",
        "tags": ["쟁반짜장", "중식"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 87,
      },
      {
        "id": 10,
        "name": "올라 광주수완점",
        "score": 78,
        "address": "광주 광산구 장신로 98",
        "distance": "1.3km",
        "tags": ["스페인음식", "파에야"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 82,
      },
      {
        "id": 11,
        "name": "봉추찜닭 수완점",
        "score": 77,
        "address": "광주 광산구 임방울대로 819",
        "distance": "1.7km",
        "tags": ["찜닭", "한식"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 79,
      },
      {
        "id": 12,
        "name": "불타는 광산곱창",
        "score": 76,
        "address": "광주 광산구 수완로 48",
        "distance": "1.5km",
        "tags": ["곱창", "막창"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 74,
      },
      {
        "id": 13,
        "name": "산수갑산 수완점",
        "score": 75,
        "address": "광주 광산구 수완로 80",
        "distance": "2.0km",
        "tags": ["닭갈비", "막걸리"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 68,
      },
      {
        "id": 14,
        "name": "더브릭 수완점",
        "score": 74,
        "address": "광주 광산구 수완로 20",
        "distance": "2.4km",
        "tags": ["양식", "피자"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 63,
      },
      {
        "id": 15,
        "name": "어게인리프레쉬",
        "score": 72,
        "address": "광주 광산구 임방울대로 800",
        "distance": "1.6km",
        "tags": ["샐러드", "그릭요거트"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 59,
      },
      {
        "id": 16,
        "name": "부억간 수완지구",
        "score": 71,
        "address": "광주 광산구 임방울대로 825",
        "distance": "1.8km",
        "tags": ["파스타", "테라스"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": true,
        "reviewCount": 54,
      },
      {
        "id": 17,
        "name": "앤티크 커피",
        "score": 70,
        "address": "광주 광산구 장신로 105",
        "distance": "1.2km",
        "tags": ["카페", "디저트"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 48,
      },
      {
        "id": 18,
        "name": "옥이네 생선구이",
        "score": 68,
        "address": "광주 광산구 장신로 61",
        "distance": "1.1km",
        "tags": ["생선구이", "백반"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 42,
      },
      {
        "id": 19,
        "name": "맥도날드 광주수완DT점",
        "score": 65,
        "address": "광주 광산구 장신로 77",
        "distance": "1.0km",
        "tags": ["패스트푸드", "버거"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 38,
      },
      {
        "id": 20,
        "name": "어니스트식스티 수완점",
        "score": 64,
        "address": "광주 광산구 임방울대로 788",
        "distance": "2.1km",
        "tags": ["스테이크", "와인"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 31,
      },
      {
        "id": 21,
        "name": "명랑회관 수완점",
        "score": 63,
        "address": "광주 광산구 수완로 75",
        "distance": "1.9km",
        "tags": ["떡볶이", "한식"],
        "image": "https://via.placeholder.com/100",
        "isBookmarked": false,
        "reviewCount": 26,
      },
    ];

    // 필터링 적용
    _filteredRestaurants = restaurants;
    if (widget.filter != null && widget.filter!.isNotEmpty) {
      _filteredRestaurants =
          restaurants
              .where(
                (restaurant) =>
                    (restaurant["tags"] as List).contains(widget.filter),
              )
              .toList();
    }

    return Column(
      children: [
        // 메인 리스트
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            itemCount:
                _isLoading
                    ? _displayCount +
                        1 // +1은 로딩 인디케이터를 위한 공간
                    : _displayCount,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.verylightGray,
                ),
            itemBuilder: (context, index) {
              // 로딩 인디케이터 표시
              if (_isLoading && index == _displayCount) {
                return _buildLoadingIndicator();
              }

              // 모든 항목이 표시된 경우
              if (index >= _filteredRestaurants.length) {
                return SizedBox.shrink();
              }

              final restaurant = _filteredRestaurants[index];

              // ListTile 대신 직접 구성한 Row 레이아웃 사용
              return GestureDetector(
                onTap: () {
                  // 음식점 상세 페이지로 이동
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽 콘텐츠 (랭킹, 식당명, 정보 등)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 랭킹 표시
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.verylightGray,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontFamily: 'Anemone',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),

                            // 식당 정보 영역
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 식당명
                                  Text(
                                    "${restaurant["name"]}",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.darkGray,
                                    ),
                                  ),

                                  // 해시태그
                                  SizedBox(height: 2),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        (restaurant["tags"] as List)
                                            .map(
                                              (tag) => Text(
                                                "#$tag",
                                                style: TextStyle(
                                                  fontFamily: 'Anemone_air',
                                                  fontSize: 12,
                                                  color: AppColors.darkGray,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),

                                  SizedBox(height: 6),
                                  // 점수, 거리, 리뷰수
                                  Row(
                                    children: [
                                      // 점수
                                      Text(
                                        "${restaurant["score"]}점",
                                        style: TextStyle(
                                          fontFamily: 'Anemone',
                                          color: AppColors.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // 거리
                                      Text(
                                        "${restaurant["distance"]}",
                                        style: TextStyle(
                                          fontFamily: 'Anemone_air',
                                          color: AppColors.darkGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // 리뷰 수 추가
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.rate_review_outlined,
                                            size: 14,
                                            color: AppColors.mediumGray,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "${restaurant["reviewCount"]}",
                                            style: TextStyle(
                                              fontFamily: 'Anemone_air',
                                              color: AppColors.mediumGray,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 4),
                                  // 주소 추가
                                  Text(
                                    "${restaurant["address"]}",
                                    style: TextStyle(
                                      fontFamily: 'Anemone_air',
                                      color: AppColors.mediumGray,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 이미지 (ListTile의 trailing 대신 Row에 직접 배치)
                      SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Container(
                            color: Colors.grey[300],
                            child: Center(child: Text('이미지')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
