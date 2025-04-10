import 'package:flutter/material.dart';
import 'package:frontend/screens/home/widgets/today_lottery.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_model.dart';
import './restaurant_card.dart';
import './local_favorite_detail.dart';

class LocalFavorites extends StatefulWidget {
  const LocalFavorites({Key? key}) : super(key: key);

  @override
  State<LocalFavorites> createState() => _LocalFavoritesState();
}

class _LocalFavoritesState extends State<LocalFavorites> {
  List<RestaurantResponse> _restaurants = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
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
        _loadNearbyRestaurants();
      }
    } catch (e) {
      print('위치 초기화 오류: $e');
      if (mounted) {
        _loadNearbyRestaurants();
      }
    }
  }

  Future<void> _loadNearbyRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition != null) {
        final restaurants = await NearbyRestaurantService.findNearbyRestaurants(
          latitude: authProvider.currentPosition!.latitude,
          longitude: authProvider.currentPosition!.longitude,
        );

        if (mounted) {
          setState(() {
            _restaurants = restaurants;
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
      print('주변 레스토랑 로딩 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '주변 레스토랑을 불러오는데 실패했습니다.';
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
      _loadNearbyRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 2 - 24;
    final gridHeight = (cardWidth + 50) * 2 + 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          thickness: 10.0,
          height: 1,
          color: AppColors.verylightGray,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gps_fixed, color: AppColors.primary, size: 14),
                  Text(
                    ' 내 주변',
                    style: baseStyle?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '추천 맛집',
                    style: baseStyle?.copyWith(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                '회원님만을 위해 준비했어요',
                style:
                    Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontSize: 16, height: 1.3)
                        .emphasized,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현지인이 선호하는 맛집',
                    style: baseStyle?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _refreshLocation,
                    child: Icon(
                      Icons.refresh,
                      color: AppColors.mediumGray,
                      size: 25,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 20.0,
              ),
              child: Column(
                children: [
                  Text(
                    _errorMessage,
                    style: baseStyle?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNearbyRestaurants,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          )
        else if (_restaurants.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text('주변에 레스토랑이 없습니다.'),
            ),
          )
        else
          SizedBox(
            height: gridHeight,
            child: PageView.builder(
              itemCount: (_restaurants.length / 4).ceil(),
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: cardWidth / (cardWidth + 50),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(
                      4.clamp(0, _restaurants.length - startIndex),
                      (index) {
                        final itemIndex = startIndex + index;
                        if (itemIndex >= _restaurants.length)
                          return const SizedBox();

                        final restaurant = _restaurants[itemIndex];

                        return RestaurantCard(
                          name: restaurant.placeName ?? '이름 없음',
                          tags: restaurant.tags,
                          distance: restaurant.distance ?? 0.0,
                          kakaoPlaceId: restaurant.kakaoPlaceId,
                          images: restaurant.restaurantImages,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocalFavoriteDetailScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkGray,
                side: BorderSide(color: AppColors.mediumGray),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('자세히 보기', style: baseStyle?.copyWith(fontSize: 14)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ),
        // 뽑기버튼
        Center(
          child: GestureDetector(
            onTap:
                _restaurants.isNotEmpty
                    ? () => FoodLotteryScreen.show(context, _restaurants)
                    : null,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '오늘의 맛집 뽑기!',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
