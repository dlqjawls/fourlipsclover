import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, pi;
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_model.dart';

class CategoryRecommendations extends StatefulWidget {
  const CategoryRecommendations({Key? key}) : super(key: key);

  @override
  State<CategoryRecommendations> createState() =>
      _CategoryRecommendationsState();
}

class _CategoryRecommendationsState extends State<CategoryRecommendations> {
  List<CategoryRestaurants> _categoryRestaurants = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // 빌드 사이클 이후로 위치 초기화 연기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {  // mounted 체크 추가
        _initializeLocation();
      }
    });
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;  // 먼저 mounted 체크
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition == null) {
        // 빌드 과정 중에는 상태 업데이트 없이 위치만 가져오기
        await authProvider.getCurrentLocation(context, notify: false);

        // 위치 정보를 가져온 후에 별도로 상태 업데이트
        if (mounted) {  // mounted 체크
          authProvider.notifyListeners();
          print(
            '위치 확인: ${authProvider.currentPosition?.latitude}, ${authProvider.currentPosition?.longitude}',
          );
        }
      }

      if (mounted) {  // mounted 체크
        _loadCategoryRestaurants();
      }
    } catch (e) {
      print('위치 초기화 오류: $e');
      if (mounted) {  // mounted 체크
        _loadCategoryRestaurants();
      }
    }
  }

  Future<void> _loadCategoryRestaurants() async {
    if (!mounted) return;  // 먼저 mounted 체크
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition != null) {
        final categoryRestaurants =
            await NearbyRestaurantService.findNearbyRestaurantsByCategory(
              latitude: authProvider.currentPosition!.longitude,
              longitude: authProvider.currentPosition!.latitude,
            );

        if (mounted) {  // mounted 체크 추가
          setState(() {
            _categoryRestaurants = categoryRestaurants;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {  // mounted 체크 추가
          setState(() {
            _errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('카테고리별 레스토랑 로딩 오류: $e');
      if (mounted) {  // mounted 체크 추가
        setState(() {
          _errorMessage = '레스토랑 정보를 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    if (!mounted) return;  // mounted 체크 추가
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentLocation(context);
    
    if (mounted) {  // mounted 체크 추가
      _loadCategoryRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            children: [
              Text(
                _errorMessage,
                style: baseStyle?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategoryRestaurants,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categoryRestaurants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('주변에 레스토랑이 없습니다.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _categoryRestaurants.length,
      itemBuilder: (context, index) {
        final category = _categoryRestaurants[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // 해시태그 아이콘
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.verylightGray,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#',
                          style:
                              baseStyle
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  )
                                  .emphasized,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 카테고리명
                      Text(
                        '${category.name} 추천',
                        style: baseStyle?.copyWith(fontSize: 18).emphasized,
                      ),
                    ],
                  ),
                  // 더보기 텍스트
                  TextButton(
                    onPressed: () {
                      // TODO: 카테고리별 레스토랑 전체 목록 화면으로 이동
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '더보기 >',
                      style: baseStyle?.copyWith(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 카테고리별 맛집 리스트
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 8),
                itemCount: category.restaurants.length,
                itemBuilder: (context, restaurantIndex) {
                  final restaurant = category.restaurants[restaurantIndex];

                  return GestureDetector(
                    onTap: () {
                      // TODO: 식당 상세 페이지로 이동
                      print(
                        '식당 클릭: ${restaurant.placeName} (ID: ${restaurant.kakaoPlaceId})',
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 맛집 이미지
                          Stack(
                            children: [
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGray,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                              ),

                              // 거리 표시
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppColors.lightGray,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${restaurant.distance?.toStringAsFixed(1) ?? '?'}km',
                                        style:
                                            baseStyle
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                )
                                                .emphasized,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 맛집 정보
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 이름과 좋아요 수 (좋아요는 서버에서 제공하지 않으므로 임시로 0 처리)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        restaurant.placeName ?? '이름 없음',
                                        style:
                                            baseStyle
                                                ?.copyWith(fontSize: 14)
                                                .emphasized,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.red.shade300,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '0', // 좋아요 수는 서버에서 제공하지 않음
                                          style: baseStyle?.copyWith(
                                            fontSize: 10,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // 위치
                                const SizedBox(height: 4),
                                Text(
                                  restaurant.roadAddressName ??
                                      restaurant.addressName ??
                                      '위치 정보 없음',
                                  style: baseStyle?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.mediumGray,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 카테고리 간 구분선
            if (index < _categoryRestaurants.length - 1)
              Column(
                children: [
                  SizedBox(height: 30),
                  Divider(
                    color: AppColors.verylightGray,
                    thickness: 10,
                    height: 1,
                  ),
                ],
              ),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }
}