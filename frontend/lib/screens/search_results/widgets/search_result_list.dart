// lib/screens/search_results/widgets/search_result_list.dart
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/search_provider.dart';
import '../../../models/restaurant_model.dart';
import '../../../widgets/clover_loading_spinner.dart';
import '../../review/restaurant_detail.dart';

class SearchResultList extends StatefulWidget {
  final String query;
  final String? filter;

  const SearchResultList({Key? key, required this.query, this.filter})
    : super(key: key);

  @override
  State<SearchResultList> createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  final int _initialItemCount = 5;
  final int _loadMoreCount = 10;
  int _displayCount = 5;
  bool _isAllLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayCount = _initialItemCount;
  }

  @override
  void didUpdateWidget(SearchResultList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 필터나 쿼리가 변경된 경우 초기 상태로 리셋
    if (widget.query != oldWidget.query || widget.filter != oldWidget.filter) {
      setState(() {
        _displayCount = _initialItemCount;
        _isAllLoaded = false;
      });
    }
  }

  // 더 많은 항목 로드
  void _loadMoreItems() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final filteredResults = _getFilteredResults(searchProvider.searchResults);

    if (!_isAllLoaded &&
        !_isLoading &&
        _displayCount < filteredResults.length) {
      setState(() {
        _isLoading = true;
      });

      // 1초 후에 데이터 로드 (로딩 시간 추가)
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _displayCount = _displayCount + _loadMoreCount;
            if (_displayCount >= filteredResults.length) {
              _displayCount = filteredResults.length;
              _isAllLoaded = true;
            }
            _isLoading = false;
          });
        }
      });
    }
  }

  // 필터 적용된 결과 가져오기
  // 필터 적용된 결과 가져오기
  List<RestaurantResponse> _getFilteredResults(
    List<RestaurantResponse> results,
  ) {
    // 결과가 비어있는 경우 빈 리스트 반환
    if (results.isEmpty) {
      return List.from(results);
    }

    // 디버깅: 각 결과의 score 출력
    for (var result in results) {
      print('Restaurant: ${result.placeName}, Score: ${result.score}');
    }

    // score 기준으로 정렬
    final sortedResults = List<RestaurantResponse>.from(results)..sort((a, b) {
      final scoreA = a.score ?? 0.0;
      final scoreB = b.score ?? 0.0;
      return scoreB.compareTo(scoreA); // 내림차순 정렬 (높은 점수가 먼저)
    });

    return sortedResults;
  }

  // 태그 정보를 기반으로 태그 위젯 생성 (박스 없이 텍스트만)
  List<Widget> _getTagWidgets(List<Map<String, dynamic>>? tags) {
    if (tags == null || tags.isEmpty) {
      return [];
    }

    // 태그를 frequency 내림차순, 동점이면 avgConfidence 내림차순으로 정렬
    final sortedTags = List<Map<String, dynamic>>.from(tags)..sort((a, b) {
      // frequency 비교 (높은 순)
      final aFreq = a['frequency'] as int?;
      final bFreq = b['frequency'] as int?;

      if (aFreq != bFreq) {
        if (aFreq == null) return 1;
        if (bFreq == null) return -1;
        return bFreq.compareTo(aFreq); // 내림차순 (높은 값이 먼저)
      }

      // frequency가 같으면 avgConfidence로 비교 (높은 순)
      final aConf = a['avgConfidence'] as num?;
      final bConf = b['avgConfidence'] as num?;
      if (aConf == null && bConf == null) return 0;
      if (aConf == null) return 1;
      if (bConf == null) return -1;
      return bConf.compareTo(aConf); // 내림차순
    });

    // 상위 3개 태그만 표시 (박스 없이 텍스트만)
    return sortedTags.take(3).map((tag) {
      return Padding(
        padding: EdgeInsets.only(right: 8),
        child: Text(
          "#${tag['tagName'] ?? ''}",
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
      );
    }).toList();
  }

  // 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Center(child: CloverLoadingSpinner(size: 50)),
    );
  }

  // 더보기 버튼 위젯
  Widget _buildLoadMoreButton() {
    return GestureDetector(
      onTap: _loadMoreItems,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.verylightGray, width: 1),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "더보기",
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 14,
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final allResults = searchProvider.searchResults;
    final filteredResults = _getFilteredResults(allResults);

    // 검색 중인 경우 로딩 스피너 표시
    if (searchProvider.isLoading) {
      return Center(child: CloverLoadingSpinner(size: 80));
    }

    // 오류가 있는 경우 오류 메시지 표시
    if (searchProvider.error != null) {
      return Center(
        child: Text(
          "검색 결과를 가져오는데 문제가 발생했습니다.\n${searchProvider.error}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 16,
            color: AppColors.darkGray,
          ),
        ),
      );
    }

    // 결과가 없는 경우
    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.lightGray),
            SizedBox(height: 16),
            Text(
              "검색 결과가 없습니다",
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${widget.query.isNotEmpty ? '"${widget.query}" 또는 ' : ''}다른 태그로 검색해보세요",
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 14,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      );
    }

    // 현재 표시할 항목 수
    int itemCount = Math.min(_displayCount, filteredResults.length);

    // 아직 모든 항목을 로드하지 않았으면 더보기 버튼 또는 로딩 인디케이터 위한 공간 추가
    if (!_isAllLoaded && filteredResults.length > _displayCount) {
      itemCount += 1;
    }

    return ListView.builder(
      primary: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,

      itemBuilder: (context, index) {
        // 마지막 항목인 경우 더보기 버튼 또는 로딩 인디케이터 표시
        if (index == _displayCount && index < filteredResults.length) {
          if (_isLoading) {
            return _buildLoadingIndicator();
          } else {
            return _buildLoadMoreButton();
          }
        }

        // 인덱스가 범위를 벗어나는 경우 빈 위젯 반환 (안전장치)
        if (index >= filteredResults.length) {
          return SizedBox.shrink();
        }

        final restaurant = filteredResults[index];

        // 음식점 아이템 UI 구성
        return Column(
          children: [
            // 첫 번째 항목 이전에는 구분선 없음
            if (index > 0)
              Divider(height: 1, thickness: 1, color: AppColors.verylightGray),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => RestaurantDetailScreen(
                          restaurantId: restaurant.kakaoPlaceId,
                        ),
                  ),
                );
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
                          // 랭킹 표시와 점수 표시를 컬럼으로 배치
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              SizedBox(height: 4),
                              // 점수 표시 추가
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${(restaurant.score ?? 0.0).toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontFamily: 'Anemone',
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " 점",
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 14,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),

                          // 식당 정보 영역
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 식당명
                                Text(
                                  restaurant.placeName ?? '이름 없음',
                                  style: TextStyle(
                                    fontFamily: 'Anemone_air',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.darkGray,
                                  ),
                                ),

                                // 태그 정보 표시
                                SizedBox(height: 4),
                                if (restaurant.tags != null &&
                                    restaurant.tags!.isNotEmpty)
                                  Wrap(
                                    children: _getTagWidgets(restaurant.tags),
                                  ),

                                SizedBox(height: 6),

                                // 주소 - 도로명 주소 우선 표시
                                Text(
                                  restaurant.addressName ?? '주소 정보 없음',
                                  style: TextStyle(
                                    fontFamily: 'Anemone_air',
                                    color: AppColors.mediumGray,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                //좋아요/싫어요 표시
                                Row(
                                  children: [
                                    // 좋아요 수 (0이어도 표시)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          size: 12,
                                          color: AppColors.mediumGray,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "${restaurant.likeSentiment ?? 0}",
                                          style: TextStyle(
                                            fontFamily: 'Anemone_air',
                                            color: AppColors.mediumGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                      ],
                                    ),

                                    // 싫어요 수 (0이어도 표시)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_down,
                                          size: 12,
                                          color: AppColors.mediumGray,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "${restaurant.dislikeSentiment ?? 0}",
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 이미지 표시
                    SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child:
                            restaurant.restaurantImages != null &&
                                    restaurant.restaurantImages!.isNotEmpty
                                ? Image.network(
                                  restaurant.restaurantImages!.first,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => _buildDefaultImage(),
                                )
                                : _buildDefaultImage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 기본 이미지 위젯
  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.lightGray,
      child: Center(
        child: Image.asset(
          'assets/images/default_image.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
