// lib/screens/group_plan/bottomsheet/restaurant_search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;
import '../../../../config/theme.dart';
import '../../../../models/restaurant_model.dart';
import '../../../../models/search_history.dart';
import '../../../../providers/search_provider.dart';
import '../../../../widgets/clover_loading_spinner.dart';
import '../../../home/widgets/search_history_item.dart';
import '../../../review/restaurant_detail.dart';

class RestaurantSearchScreen extends StatefulWidget {
  const RestaurantSearchScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;

  final int _initialItemCount = 5;
  final int _loadMoreCount = 10;
  int _displayCount = 5;
  bool _isAllLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayCount = _initialItemCount;

    // 화면 진입 시 검색 결과 초기화 및 히스토리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      // 이전 검색 결과 초기화
      searchProvider.clearSearchResults();
      // 검색 히스토리 로드
      searchProvider.loadSearchHistory();
    });

    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 검색 실행 메서드
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      searchProvider.addSearchHistory(query);
      searchProvider.fetchSearchResults(query);
      FocusScope.of(context).unfocus();

      // 상태 초기화
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

      // 1초 후에 데이터 로드
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
  List<RestaurantResponse> _getFilteredResults(
    List<RestaurantResponse> results,
  ) {
    if (results.isEmpty) {
      return List.from(results);
    }

    // score 기준으로 정렬
    final sortedResults = List<RestaurantResponse>.from(results)..sort((a, b) {
      final scoreA = a.score ?? 0.0;
      final scoreB = b.score ?? 0.0;
      return scoreB.compareTo(scoreA); // 내림차순 정렬 (높은 점수가 먼저)
    });

    return sortedResults;
  }

  // 태그 정보를 기반으로 태그 위젯 생성
  List<Widget> _getTagWidgets(List<Map<String, dynamic>>? tags) {
    if (tags == null || tags.isEmpty) {
      return [];
    }

    // 태그를 frequency 내림차순, 동점이면 avgConfidence 내림차순으로 정렬
    final sortedTags = List<Map<String, dynamic>>.from(tags)..sort((a, b) {
      final aFreq = a['frequency'] as int?;
      final bFreq = b['frequency'] as int?;

      if (aFreq != bFreq) {
        if (aFreq == null) return 1;
        if (bFreq == null) return -1;
        return bFreq.compareTo(aFreq);
      }

      final aConf = a['avgConfidence'] as num?;
      final bConf = b['avgConfidence'] as num?;
      if (aConf == null && bConf == null) return 0;
      if (aConf == null) return 1;
      if (bConf == null) return -1;
      return bConf.compareTo(aConf);
    });

    // 상위 3개 태그만 표시
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

  // 레스토랑 선택 처리
  void _selectRestaurant(RestaurantResponse restaurant) {
    // 선택된 레스토랑 정보를 이전 화면으로 반환
    Navigator.pop(context, restaurant);
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

  // 레스토랑 아이템 빌드
  Widget _buildRestaurantItem(RestaurantResponse restaurant, int index) {
    return Column(
      children: [
        if (index > 0)
          Divider(height: 1, thickness: 1, color: AppColors.verylightGray),
        GestureDetector(
          onTap: () => _selectRestaurant(restaurant),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Text(
                            "${(restaurant.score ?? 0.0).toStringAsFixed(0)}점",
                            style: TextStyle(
                              fontFamily: 'Anemone',
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.placeName ?? '이름 없음',
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.darkGray,
                              ),
                            ),
                            SizedBox(height: 4),
                            if (restaurant.tags != null &&
                                restaurant.tags!.isNotEmpty)
                              Wrap(children: _getTagWidgets(restaurant.tags)),
                            SizedBox(height: 6),
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
                            Row(
                              children: [
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: '레스토랑을 검색하세요',
            hintStyle: TextStyle(color: AppColors.mediumGray, fontSize: 16),
            border: InputBorder.none,
            suffixIcon:
                _showClearButton
                    ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.mediumGray),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                    : IconButton(
                      icon: Icon(Icons.search, color: AppColors.primary),
                      onPressed: _performSearch,
                    ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          // 로딩 상태 처리
          if (searchProvider.isLoading) {
            return const Center(child: CloverLoadingSpinner());
          }

          // 에러 상태 처리
          if (searchProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '검색 중 오류가 발생했습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final allResults = searchProvider.searchResults;
          final filteredResults = _getFilteredResults(allResults);

          // 결과가 없는 경우
          if (filteredResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '다른 키워드로 검색해보세요',
                    style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
                  ),
                ],
              ),
            );
          }

          // 현재 표시할 항목 수
          int itemCount = Math.min(_displayCount, filteredResults.length);

          // 더보기 버튼 또는 로딩 인디케이터를 위한 공간 추가
          if (!_isAllLoaded && filteredResults.length > _displayCount) {
            itemCount += 1;
          }

          return ListView.builder(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // 더보기 버튼 또는 로딩 인디케이터 표시
              if (index == _displayCount && index < filteredResults.length) {
                if (_isLoading) {
                  return _buildLoadingIndicator();
                } else {
                  return _buildLoadMoreButton();
                }
              }

              // 인덱스가 범위를 벗어나는 경우 빈 위젯 반환
              if (index >= filteredResults.length) {
                return const SizedBox.shrink();
              }

              final restaurant = filteredResults[index];
              return _buildRestaurantItem(restaurant, index);
            },
          );
        },
      ),
    );
  }
}
