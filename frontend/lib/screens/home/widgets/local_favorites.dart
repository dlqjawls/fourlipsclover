import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, pi;
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_model.dart';

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
      if (mounted) { // mounted 체크 추가
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
          latitude: authProvider.currentPosition!.longitude,
          longitude: authProvider.currentPosition!.latitude,
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

        if (mounted) { // mounted 체크 추가
          setState(() {
            _restaurants = restaurants;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) { // mounted 체크 추가
          setState(() {
            _errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('주변 레스토랑 로딩 오류: $e');
      if (mounted) { // mounted 체크 추가
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
    
    if (mounted) { // mounted 체크 추가
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 주변',
                        style: baseStyle?.copyWith(fontSize: 18).emphasized,
                      ),
                      Text(
                        '현지인이 선호하는 맛집',
                        style: baseStyle?.copyWith(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TextButton(
                onPressed: _refreshLocation,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  backgroundColor: AppColors.verylightGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: AppColors.darkGray, size: 14),
                    const SizedBox(width: 4),
                    Text('지역 갱신', style: baseStyle?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
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

                        // 거리 계산 - 현재 위치와 식당 위치가 모두 있을 때만
                        double distance = 0.0;
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        if (authProvider.currentPosition != null &&
                            restaurant.x != null &&
                            restaurant.y != null) {
                          final dx =
                              111.3 *
                              cos(
                                authProvider.currentPosition!.latitude *
                                    pi /
                                    180,
                              ) *
                              (authProvider.currentPosition!.longitude -
                                  restaurant.x!);
                          final dy =
                              111.3 *
                              (authProvider.currentPosition!.latitude -
                                  restaurant.y!);
                          distance = sqrt(dx * dx + dy * dy);
                        }

                        return RestaurantCard(
                          name: restaurant.placeName ?? '이름 없음',
                          address: restaurant.roadAddressName ?? '주소 없음',
                          category: restaurant.category ?? '',
                          phone: restaurant.phone ?? '전화번호 없음',
                          likes: 0, // 서버에서 제공하지 않는 정보
                          hashtags: hashtags,
                          distance: distance,
                          kakaoPlaceId: restaurant.kakaoPlaceId ?? '',
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
                // TODO: 주변 레스토랑 전체 목록 화면으로 이동
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

// RestaurantCard 위젯은 변경 없음
class RestaurantCard extends StatelessWidget {
  final String name;
  final String address;
  final String category;
  final String phone;
  final int likes;
  final List<String> hashtags;
  final double distance;
  final String kakaoPlaceId;

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.address,
    required this.category,
    required this.phone,
    this.likes = 0,
    this.hashtags = const [],
    this.distance = 0.0,
    required this.kakaoPlaceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return GestureDetector(
      onTap: () {
        // TODO: 식당 상세 페이지로 이동
        print('식당 클릭: $name (ID: $kakaoPlaceId)');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 내용에 맞게 최소 높이로 조정
          children: [
            // 식당 이미지 (임시로 회색 박스)
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.lightGray,
                ),

                // 거리 정보 (상단 왼쪽)
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
                          '${distance.toStringAsFixed(1)}km',
                          style:
                              baseStyle
                                  ?.copyWith(color: Colors.white, fontSize: 10)
                                  .emphasized,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 식당 정보
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 식당 이름과 좋아요 수 한 줄에
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: baseStyle?.copyWith(fontSize: 15).emphasized,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // 좋아요 수
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red.shade300,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$likes',
                              style: baseStyle?.copyWith(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 추가 정보
                    const SizedBox(height: 6),
                    Text(
                      address,
                      style: baseStyle?.copyWith(
                        fontSize: 11,
                        color: AppColors.darkGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: baseStyle?.copyWith(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: baseStyle?.copyWith(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 해시태그
                    if (hashtags.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 22,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              hashtags
                                  .take(3)
                                  .map((tag) => _buildHashtagChip(context, tag))
                                  .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 회색 해시태그 디자인
  Widget _buildHashtagChip(BuildContext context, String tag) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.verylightGray, // 회색 배경
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: baseStyle?.copyWith(
          fontSize: 10,
          color: AppColors.mediumGray, // 회색 텍스트
        ),
      ),
    );
  }
}