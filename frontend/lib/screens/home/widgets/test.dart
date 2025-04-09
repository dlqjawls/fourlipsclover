import 'package:flutter/material.dart';
import 'dart:math';
import '../../../config/theme.dart';
import '../../../models/restaurant_model.dart';
import '../../review/restaurant_detail.dart';

class FoodLotteryScreen extends StatefulWidget {
  final List<RestaurantResponse> restaurants;

  const FoodLotteryScreen({Key? key, required this.restaurants}) : super(key: key);

  static void show(BuildContext context, List<RestaurantResponse> restaurants) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => FoodLotteryScreen(restaurants: restaurants),
    );
  }

  @override
  _FoodLotteryScreenState createState() => _FoodLotteryScreenState();
}

class _FoodLotteryScreenState extends State<FoodLotteryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<LotteryBall> _balls = [];
  RestaurantResponse? _selectedRestaurant;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 공 생성
    _initializeBalls();
  }

  void _initializeBalls() {
    final random = Random();
    final screenWidth = 300.0;
    final screenHeight = 500.0;

    _balls = List.generate(15, (index) {
      return LotteryBall(
        id: index,
        color: _getRandomColor(),
        initialPosition: Offset(
          random.nextDouble() * screenWidth,
          random.nextDouble() * screenHeight
        ),
        controller: _controller,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Color(0xFFFF5252),   // 빨강
      Color(0xFF4CAF50),   // 초록
      Color(0xFF2196F3),   // 파랑
      Color(0xFFFFC107),   // 노랑
      Color(0xFF9C27B0),   // 보라
      Color(0xFFFF9800),   // 주황
      Color(0xFF795548),   // 갈색
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _startLottery() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedRestaurant = null;
    });

    _controller.forward(from: 0.0);

    // 3초 후 최종 선택
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _selectedRestaurant = widget.restaurants[Random().nextInt(widget.restaurants.length)];
        _isSpinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 로또 볼 애니메이션
          ...List.generate(_balls.length, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: _balls[index].position.dx,
                  top: _balls[index].position.dy,
                  child: _buildLotteryBall(_balls[index]),
                );
              },
            );
          }),

          // 뽑기 버튼
          Positioned(
            bottom: 50,
            child: ElevatedButton(
              onPressed: _isSpinning ? null : _startLottery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isSpinning ? '선택 중...' : '오늘의 맛집 뽑기',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 결과 표시
          if (_selectedRestaurant != null)
            Positioned(
              bottom: 150,
              child: _buildResultCard(),
            ),

          // 닫기 버튼
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotteryBall(LotteryBall ball) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: ball.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${ball.id + 1}', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(
                    restaurantId: _selectedRestaurant!.kakaoPlaceId,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 250,
                height: 150,
                child: _selectedRestaurant!.restaurantImages != null && 
                       _selectedRestaurant!.restaurantImages!.isNotEmpty
                  ? Image.network(
                      _selectedRestaurant!.restaurantImages!.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultImage();
                      },
                    )
                  : _buildDefaultImage(),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            _selectedRestaurant!.placeName ?? '맛집',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkest,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on, 
                size: 16, 
                color: AppColors.primary,
              ),
              SizedBox(width: 5),
              Text(
                _selectedRestaurant!.distance != null 
                  ? '${_selectedRestaurant!.distance!.toStringAsFixed(1)} km' 
                  : '거리 정보 없음',
                style: TextStyle(
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 로또 공 클래스
class LotteryBall {
  final int id;
  final Color color;
  Offset position;
  final AnimationController controller;

  LotteryBall({
    required this.id,
    required this.color,
    Offset? initialPosition,
    required this.controller,
  }) : position = initialPosition ?? Offset.zero {
    // 애니메이션 중 위치 업데이트
    controller.addListener(_updatePosition);
  }

  void _updatePosition() {
    final random = Random();
    
    // 부드러운 무작위 움직임 생성
    double dx = position.dx + (random.nextDouble() - 0.5) * 10;
    double dy = position.dy + (random.nextDouble() - 0.5) * 10;

    // 화면 경계 제한
    dx = dx.clamp(0, 250);
    dy = dy.clamp(0, 500);

    position = Offset(dx, dy);
  }
}