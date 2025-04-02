// lib/screens/search_results/search_results_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/map_preview.dart';
import '../../providers/search_provider.dart';
import '../../providers/map_provider.dart';
import '../../models/restaurant_model.dart';
import '../../widgets/clover_loading_spinner.dart';
import 'widgets/search_filter_tags.dart';
import 'widgets/search_result_list.dart';
import '../../utils/map_utils.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final List<String> selectedTags; // 해시태그 목록으로 변경 (추가)

  const SearchResultsScreen({
    Key? key,
    required this.searchQuery,
    this.selectedTags = const [], // 기본값은 빈 목록 (추가)
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late String _currentQuery;
  String? _selectedFilter;
  List<String> _selectedTags = []; // 선택된 태그 목록 (추가)
  final TextEditingController _searchController = TextEditingController();
  int _resultCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _selectedFilter =
        widget.selectedTags.isNotEmpty ? widget.selectedTags.first : null; // 수정
    _selectedTags = List.from(widget.selectedTags); // 태그 목록 복사 (추가)
    _searchController.text = _currentQuery;

    // 빌드 사이클 완료 후 검색 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _executeSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _executeSearch() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // 검색 실행 (태그는 아직 사용하지 않음)
    final results = await searchProvider.fetchSearchResults(_currentQuery);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _resultCount = results.length;
      });

      // 지도에 라벨 추가
      if (results.isNotEmpty) {
        _addLabelsToMap(results, mapProvider);
      }
    }
  }

  // 기존 _addLabelsToMap 메소드는 그대로 유지

  void _addLabelsToMap(
    List<RestaurantResponse> restaurants,
    MapProvider mapProvider,
  ) {
    // 기존 라벨 모두 제거
    mapProvider.clearLabels();

    print('지도에 라벨 추가: 총 ${restaurants.length}개 식당 검색됨');

    // 각 레스토랑 정보 로깅
    for (var restaurant in restaurants) {
      print(
        '식당: ${restaurant.placeName}, 좌표: x=${restaurant.x}, y=${restaurant.y}',
      );
    }

    // 유효한 좌표가 있는 식당만 필터링
    final validRestaurants =
        restaurants.where((r) => r.y != null && r.x != null).toList();

    print('유효한 좌표가 있는 식당: ${validRestaurants.length}개');

    // 바운딩 박스 계산을 위한 변수들
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    // 각 식당마다 라벨 추가
    int addedCount = 0;
    for (var restaurant in validRestaurants) {
      try {
        print(
          '라벨 추가 시도: ${restaurant.placeName}, y=${restaurant.y}, x=${restaurant.x}',
        );

        mapProvider.addLabel(
          id: restaurant.kakaoPlaceId,
          latitude: restaurant.y!, // 중요: 여기서 y가 위도
          longitude: restaurant.x!, // 중요: 여기서 x가 경도
          text: restaurant.placeName ?? "식당",
          imageAsset: 'clover',
          textSize: 24.0,
          zIndex: 1,
          isClickable: false,
        );

        addedCount++;

        // 바운딩 박스 업데이트
        if (restaurant.y! < minLat) minLat = restaurant.y!;
        if (restaurant.y! > maxLat) maxLat = restaurant.y!;
        if (restaurant.x! < minLng) minLng = restaurant.x!;
        if (restaurant.x! > maxLng) maxLng = restaurant.x!;
      } catch (e) {
        print('라벨 추가 실패: ${restaurant.placeName}, 오류: $e');
      }
    }

    print('라벨 추가 완료: $addedCount개');

    // 라벨이 추가된 식당이 있으면 지도 중심 설정
    if (addedCount > 0) {
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      print('지도 중심 설정: lat=$centerLat, lng=$centerLng');

      mapProvider.setMapCenter(
        latitude: centerLat,
        longitude: centerLng,
        zoomLevel: 14,
      );
    }

    print('지도에 ${mapProvider.labels.length}개 라벨 추가 완료');
  }

  // 태그 제거 처리 (추가)
  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      // 선택된 필터 업데이트
      _selectedFilter = _selectedTags.isNotEmpty ? _selectedTags.first : null;
    });
    // 실제 검색은 태그와 관계없이 수행하므로 여기서는 재검색 안 함
  }

  // 필터 변경 처리 (수정)
  void _handleFilterChanged(String filter) {
    setState(() {
      if (_selectedFilter == filter) {
        // 이미 선택된 필터를 다시 탭하면 해제
        _selectedFilter = null;
        _selectedTags.remove(filter);
      } else {
        _selectedFilter = filter;
        // 태그 목록에 추가 (중복 방지)
        if (!_selectedTags.contains(filter)) {
          _selectedTags.add(filter);
        }
      }
    });
  }

  // 지도 전체 화면으로 전환
  void _openFullMap() {
    Navigator.pushNamed(
      context,
      '/full_map',
      arguments: {'locationName': _currentQuery},
    );
  }

  // 새 검색 화면으로 이동
  void _navigateToSearch() {
    // TODO: 실제 구현 시 Navigator.push를 사용하여 검색 화면으로 이동
    print('검색 화면으로 이동');
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0.5,
            scrolledUnderElevation: 0.5,
            shadowColor: AppColors.mediumGray.withOpacity(0.05),
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Center(
              child: Row(
                children: [
                  // 뒤로가기 버튼
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8),
                      iconSize: 28,
                    ),
                  ),

                  // 검색 바
                  Expanded(
                    child: GestureDetector(
                      onTap: _navigateToSearch,
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(right: 12, left: 4),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.verylightGray,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentQuery,
                                style: TextStyle(
                                  fontFamily: 'Anemone_air',
                                  fontSize: 16,
                                  color: AppColors.darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // X 버튼
                            GestureDetector(
                              onTap: _navigateToSearch,
                              child: Icon(
                                Icons.close,
                                color: AppColors.mediumGray,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            return false;
          },
          child: NestedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // 검색 결과 카운트 표시
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "$_currentQuery",
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 18,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " 맛집 (",
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 18,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "$_resultCount",
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "곳)",
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                        fontSize: 18,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: AppColors.darkGray,
                                ),
                                onPressed: () {
                                  // 공유 기능 구현
                                },
                              ),
                            ],
                          ),
                        ),

                        // 선택된 태그가 있으면 표시 (추가)
                        if (_selectedTags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '선택된 태그:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _selectedTags
                                          .map((tag) => _buildTagChip(tag))
                                          .toList(),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),

                        // 지도 미리보기
                        MapPreview(
                          location: _currentQuery,
                          onTapViewMap: _openFullMap,
                        ),

                        // 필터 태그
                        SearchFilterTags(
                          selectedFilter: _selectedFilter,
                          onFilterChanged: _handleFilterChanged,
                          locationName: _currentQuery,
                        ),

                        // 구분선
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.verylightGray,
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: SearchResultList(
              query: _currentQuery,
              filter: _selectedFilter,
            ),
          ),
        ),
      ),
    );
  }

  // 태그 칩 위젯 빌드 (추가)
  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mediumGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(Icons.close, size: 12, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }
}
