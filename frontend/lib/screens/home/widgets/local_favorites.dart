import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, pi;
import '../../../config/theme.dart';
import '../../../utils/text_style_extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_models.dart';

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
  // 앱 시작 시 위치를 먼저 확인한 후 레스토랑 로딩
  _initializeLocation();
}

// 위치 초기화 후 레스토랑 로드
Future<void> _initializeLocation() async {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 현재 위치가 없는 경우에만 위치 정보 요청
    if (authProvider.currentPosition == null) {
      await authProvider.getCurrentLocation(context);
      print('initState에서 위치 확인: ${authProvider.currentPosition?.latitude}, ${authProvider.currentPosition?.longitude}');
    }
    
    // 위치 정보 획득 후 레스토랑 로드
    _loadNearbyRestaurants();
  } catch (e) {
    print('위치 초기화 오류: $e');
    // 오류가 있어도 레스토랑 로딩 시도
    _loadNearbyRestaurants();
  }
}

  // 주변 레스토랑 데이터 로딩
  Future<void> _loadNearbyRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 위치 정보가 있는 경우
      if (authProvider.currentPosition != null) {
        final restaurants = await NearbyRestaurantService.findNearbyRestaurants(
          latitude: authProvider.currentPosition!.latitude,
          longitude: authProvider.currentPosition!.longitude,
        );
        
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      } else {
        // 위치 정보가 없는 경우
        setState(() {
          _errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('주변 레스토랑 로딩 오류: $e');
      setState(() {
        _errorMessage = '주변 레스토랑을 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  // 위치 정보 갱신 및 레스토랑 다시 로딩
  Future<void> _refreshLocation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 위치 정보 갱신 요청
    await authProvider.getCurrentLocation(context);
    
    // 갱신된 위치로 레스토랑 다시 로딩
    _loadNearbyRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 구분선
        const Divider(
          thickness: 10.0,
          height: 1,
          color: AppColors.verylightGray,
        ),

        // 제목 영역 - 디자인 개선
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 좌측 - 내 주변 + 아이콘
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

              // 우측 - 지역 변경 버튼 (위치 갱신 기능 추가)
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

        // 로딩 상태 또는 에러 메시지 표시
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
          // 2x2 그리드 형태로 식당 표시 (페이징 가능)
          SizedBox(
            height: 500,
            child: PageView.builder(
              itemCount: (_restaurants.length / 4).ceil(), // 4개씩 페이지 계산
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.78, // 비율 조정
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
                        final categories = restaurant.categoryName?.split(' > ') ?? [];
                        final hashtags = categories.map((cat) => '#$cat').toList();
                        
                        // 거리 계산 - 현재 위치와 식당 위치가 모두 있을 때만
                        double distance = 0.0;
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        
                        if (authProvider.currentPosition != null && 
                            restaurant.x != null && restaurant.y != null) {
                          // 간단한 거리 계산 (km 단위)
                          final dx = 111.3 * cos(authProvider.currentPosition!.latitude * pi / 180) * 
                                    (authProvider.currentPosition!.longitude - restaurant.x!);
                          final dy = 111.3 * (authProvider.currentPosition!.latitude - restaurant.y!);
                          distance = sqrt(dx * dx + dy * dy);
                        }

                        return RestaurantCard(
                          name: restaurant.placeName ?? '이름 없음',
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

        // 자세히 보기 버튼 - 회색으로 변경
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

// 수정된 식당 카드 위젯
class RestaurantCard extends StatelessWidget {
  final String name;
  final int likes;
  final List<String> hashtags;
  final double distance;
  final String kakaoPlaceId;

  const RestaurantCard({
    Key? key,
    required this.name,
    this.likes = 0,  // 기본값 설정
    this.hashtags = const [],  // 기본값 설정
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 식당 이미지 (임시로 회색 박스)
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.lightGray,
                ),

                // 거리 정보 (상단 왼쪽) - 지도 아이콘으로 변경, 반투명 회색 배경
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2), // 반투명 회색
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

            // 식당 정보 - 컴팩트하고 세련되게
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                      // 좋아요 수 (아이콘과 숫자만)
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

                  // 해시태그 (회색 스타일로 변경)
                  if (hashtags.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 22, // 고정 높이로 공간 최소화
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