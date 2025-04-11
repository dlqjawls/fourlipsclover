import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_model.dart';
import './restaurant_card.dart';

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
      if (mounted) {
        _initializeLocation();
      }
    });
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition == null) {
        await authProvider.getCurrentLocation(context, notify: false);

        if (mounted) {
          authProvider.notifyListeners();
        }
      }

      if (mounted) {
        _loadCategoryRestaurants();
      }
    } catch (e) {
      print('위치 초기화 오류: $e');
      if (mounted) {
        _loadCategoryRestaurants();
      }
    }
  }

  Future<void> _loadCategoryRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition != null) {
        final categoryRestaurants =
            await NearbyRestaurantService.findNearbyRestaurantsByCategory(
              latitude: authProvider.currentPosition!.latitude,
              longitude: authProvider.currentPosition!.longitude,
            );

        if (mounted) {
          setState(() {
            _categoryRestaurants = categoryRestaurants;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('카테고리별 레스토랑 로딩 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '레스토랑 정보를 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentLocation(context);

    if (mounted) {
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
                              ?.copyWith(fontSize: 16, color: AppColors.primary)
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
            ),

            // 카테고리별 맛집 리스트 - 가로 스크롤
            SizedBox(
              height: 260, // 이미지 + 텍스트 영역에 맞게 높이 조정
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 8),
                itemCount: category.restaurants.length,
                itemBuilder: (context, restaurantIndex) {
                  final restaurant = category.restaurants[restaurantIndex];

                  // 업데이트된 RestaurantCard 위젯 사용
                  return Container(
                    width: 160, // 카드 너비
                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                    child: RestaurantCard(
                      name: restaurant.placeName ?? '이름 없음',
                      tags: restaurant.tags,
                      distance: restaurant.distance ?? 0.0,
                      kakaoPlaceId: restaurant.kakaoPlaceId,
                      images: restaurant.restaurantImages,
                    ),
                  );
                },
              ),
            ),

            // 카테고리 간 구분선
            if (index < _categoryRestaurants.length - 1)
              Column(
                children: [
                  SizedBox(height: 20),
                  Divider(
                    color: AppColors.verylightGray,
                    thickness: 10,
                    height: 1,
                  ),
                ],
              ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
