// lib/screens/home/widgets/local_favorite_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, pi;
import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nearby_restaurant_service.dart';
import '../../../models/restaurant_model.dart';
import '../../review/restaurant_detail.dart';

class LocalFavoriteDetailScreen extends StatefulWidget {
  const LocalFavoriteDetailScreen({Key? key}) : super(key: key);

  @override
  State<LocalFavoriteDetailScreen> createState() => _LocalFavoriteDetailScreenState();
}

class _LocalFavoriteDetailScreenState extends State<LocalFavoriteDetailScreen> {
  List<RestaurantResponse> _restaurants = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNearbyRestaurants();
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

        // 각 식당마다 거리 계산
        for (var restaurant in restaurants) {
          if (restaurant.x != null && restaurant.y != null) {
            final dx = 111.3 *
                cos(authProvider.currentPosition!.latitude * pi / 180) *
                (authProvider.currentPosition!.longitude - restaurant.x!);
            final dy = 111.3 *
                (authProvider.currentPosition!.latitude - restaurant.y!);
            restaurant.distance = sqrt(dx * dx + dy * dy);
          } else {
            restaurant.distance = double.infinity; // 위치 정보가 없는 경우
          }
        }

        // 거리순으로 정렬
        restaurants.sort(
          (a, b) => (a.distance ?? double.infinity)
              .compareTo(b.distance ?? double.infinity),
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

  Future<void> _refreshList() async {
    await _loadNearbyRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('주변 맛집 리스트'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshList,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNearbyRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Text('주변에 맛집이 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshList,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _restaurants.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return _buildRestaurantListItem(restaurant);
        },
      ),
    );
  }

  Widget _buildRestaurantListItem(RestaurantResponse restaurant) {
    // 카테고리 분리 (해시태그로 변환)
    final categories = restaurant.categoryName?.split(' > ') ?? [];
    final hashtags = categories.map((cat) => '#$cat').toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              restaurantId: restaurant.kakaoPlaceId ?? '',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 식당 이미지 (임시로 회색 박스)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.lightGray,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              
              // 식당 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 식당 이름
                    Text(
                      restaurant.placeName ?? '이름 없음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
                    // 주소
                    Text(
                      restaurant.roadAddressName ?? '주소 없음',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
                    // 카테고리
                    Text(
                      restaurant.category ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    // 해시태그
                    if (hashtags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: hashtags
                            .take(3)
                            .map((tag) => _buildHashtagChip(tag))
                            .toList(),
                      ),
                  ],
                ),
              ),
              
              // 거리 표시
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.verylightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(restaurant.distance ?? 0) * 1000 > 0 ? (restaurant.distance! * 1000).round() : 0} m',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHashtagChip(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.verylightGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.mediumGray,
        ),
      ),
    );
  }
}