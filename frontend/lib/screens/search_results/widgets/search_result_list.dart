// lib/screens/search_results/widgets/search_result_list.dart
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/search_provider.dart';
import '../../../models/restaurant_model.dart';
import '../../../widgets/clover_loading_spinner.dart';

class SearchResultList extends StatefulWidget {
  final String query;
  final String? filter;

  const SearchResultList({
    Key? key,
    required this.query,
    this.filter,
  }) : super(key: key);

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
    
    if (!_isAllLoaded && !_isLoading && _displayCount < filteredResults.length) {
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
  List<RestaurantResponse> _getFilteredResults(List<RestaurantResponse> results) {
    if (widget.filter != null && widget.filter!.isNotEmpty) {
      // 카테고리 기준으로 필터링
      return results.where((restaurant) {
        final category = restaurant.category ?? "";
        return category.contains(widget.filter!);
      }).toList();
    }
    return List.from(results);
  }

  // 카테고리 텍스트를 해시태그로 변환
  List<Widget> _getCategoryTags(String? category) {
    if (category == null || category.isEmpty) {
      return [
        Text(
          "#식당",
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
      ];
    }
    
    // "음식점 > 한식 > 육류,고기" 형태에서 태그 추출
    final parts = category.split(' > ');
    return parts.skip(1).map((tag) => 
      Text(
        "#$tag",
        style: TextStyle(
          fontFamily: 'Anemone_air',
          fontSize: 12,
          color: AppColors.darkGray,
        ),
      )
    ).toList();
  }

  // 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Center(
        child: CloverLoadingSpinner(size: 50),
      ),
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
            top: BorderSide(
              color: AppColors.verylightGray,
              width: 1,
            ),
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
      return Center(
        child: CloverLoadingSpinner(size: 80),
      );
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
        child: Text(
          "검색 결과가 없습니다.",
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 16,
            color: AppColors.darkGray,
          ),
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
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.verylightGray,
              ),
            GestureDetector(
              onTap: () {
                // 음식점 상세 페이지로 이동 (나중에 구현)
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
                                  "${restaurant.placeName ?? '이름 없음'}",
                                  style: TextStyle(
                                    fontFamily: 'Anemone_air',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.darkGray,
                                  ),
                                ),

                                // 해시태그 - 카테고리를 기반으로 해시태그 생성
                                SizedBox(height: 2),
                                Wrap(
                                  spacing: 8,
                                  children: _getCategoryTags(restaurant.category),
                                ),

                                SizedBox(height: 6),
                                // 거리 (있는 경우)
                                Row(
                                  children: [
                                    if (restaurant.distance != null)
                                      Text(
                                        "${restaurant.distance!.toStringAsFixed(1)}km",
                                        style: TextStyle(
                                          fontFamily: 'Anemone_air',
                                          color: AppColors.darkGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                    SizedBox(width: 10),
                                    // 전화번호가 있는 경우
                                    if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                                      Text(
                                        "${restaurant.phone}",
                                        style: TextStyle(
                                          fontFamily: 'Anemone_air',
                                          color: AppColors.mediumGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 4),
                                // 주소
                                Text(
                                  "${restaurant.addressName ?? restaurant.roadAddressName ?? '주소 정보 없음'}",
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

                    // 이미지 (실제 이미지는 아직 없으므로 임시 UI)
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
            ),
          ],
        );
      },
    );
  }
}