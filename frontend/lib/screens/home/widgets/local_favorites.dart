import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, pi;
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

    // 빌드 사이클 완료 후에 실행하도록 스케줄링
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // mounted 체크 추가
        _initializeLocation();
      }
    });
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return; // mounted 체크 추가

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentPosition == null) {
        // 빌드 과정에서는 상태 변경 알림 없이 위치 정보만 가져오기
        await authProvider.getCurrentLocation(context, notify: false);

        // 위치 정보를 가져온 후 별도로 상태 업데이트
        if (mounted) {
          authProvider.notifyListeners();
        }
      }

      if (mounted) {
        _loadNearbyRestaurants(); // 또는 해당 위젯의 데이터 로드 메서드
      }
    } catch (e) {
      print('위치 초기화 오류: $e');
      if (mounted) {
        _loadNearbyRestaurants(); // 또는 해당 위젯의 데이터 로드 메서드
      }
    }
  }

  Future<void> _loadNearbyRestaurants() async {
    if (!mounted) return; // mounted 체크 추가

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

        // 각 식당마다 거리 계산
        for (var restaurant in restaurants) {
          if (restaurant.x != null && restaurant.y != null) {
            final dx =
                111.3 *
                cos(authProvider.currentPosition!.latitude * pi / 180) *
                (authProvider.currentPosition!.longitude - restaurant.x!);
            final dy =
                111.3 *
                (authProvider.currentPosition!.latitude - restaurant.y!);
            restaurant.distance = sqrt(dx * dx + dy * dy);
          } else {
            restaurant.distance = double.infinity; // 위치 정보가 없는 경우
          }
        }

        // 거리순으로 정렬
        restaurants.sort(
          (a, b) => (a.distance ?? double.infinity).compareTo(
            b.distance ?? double.infinity,
          ),
        );

        if (mounted) {
          // mounted 체크 추가
          setState(() {
            _restaurants = restaurants;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          // mounted 체크 추가
          setState(() {
            _errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('주변 레스토랑 로딩 오류: $e');
      if (mounted) {
        // mounted 체크 추가
        setState(() {
          _errorMessage = '주변 레스토랑을 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    if (!mounted) return; // mounted 체크 추가

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentLocation(context);

    if (mounted) {
      // mounted 체크 추가
      _loadNearbyRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

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

              // 현지인이 선호하는 맛집 + 새로고침 아이콘 (한 줄에 함께 표시)
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
            height: 500,
            child: PageView.builder(
              itemCount: (_restaurants.length / 4).ceil(),
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(
                      4.clamp(0, _restaurants.length - startIndex),
                      (index) {
                        final itemIndex = startIndex + index;
                        if (itemIndex >= _restaurants.length)
                          return const SizedBox();

                        final restaurant = _restaurants[itemIndex];

                        // 카테고리 분리 (해시태그로 변환)
                        final categories =
                            restaurant.categoryName?.split(' > ') ?? [];
                        final hashtags =
                            categories.map((cat) => '#$cat').toList();

                        return RestaurantCard(
                          name: restaurant.placeName ?? '이름 없음',
                          address: restaurant.roadAddressName ?? '주소 없음',
                          category: restaurant.category ?? '',
                          phone: restaurant.phone ?? '전화번호 없음',
                          likes: 0, // 서버에서 제공하지 않는 정보
                          hashtags: hashtags,
                          distance: restaurant.distance ?? 0.0,
                          kakaoPlaceId: restaurant.kakaoPlaceId ?? '',
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

        // local_favorites.dart의 자세히 보기 버튼 부분 수정
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: OutlinedButton(
              onPressed: () {
                // 자세히 보기 버튼 클릭 시 LocalFavoriteDetailScreen으로 이동
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
      ],
    );
  }
}
