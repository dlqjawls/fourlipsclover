import 'package:flutter/material.dart';
import 'dart:math';
import '../../../config/theme.dart';
import '../../../models/restaurant_model.dart';
import '../../review/restaurant_detail.dart';

class FoodLotteryScreen extends StatefulWidget {
  final List<RestaurantResponse> restaurants;

  const FoodLotteryScreen({Key? key, required this.restaurants})
    : super(key: key);

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

class _FoodLotteryScreenState extends State<FoodLotteryScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<LotteryBall> _balls = [];
  RestaurantResponse? _selectedRestaurant;
  bool _isSpinning = false;
  late AnimationController _resultController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _resultController, curve: Curves.easeIn));

    // 공 생성
    _initializeBalls();
  }

  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      // 1km 미만이면 미터로 표시
      int meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      // 1km 이상이면 소수점 2자리까지 km로 표시
      return '${distanceInKm.toStringAsFixed(2)} km';
    }
  }

  void _initializeBalls() {
    final random = Random();
    final screenWidth = 300.0;
    final screenHeight = 500.0;

    _balls = List.generate(30, (index) {
      return LotteryBall(
        id: index,
        color: _getRandomColor(),
        initialPosition: Offset(
          random.nextDouble() * screenWidth,
          random.nextDouble() * screenHeight,
        ),
        initialVelocity: Offset(
          (random.nextDouble() - 0.5) * 10, // 속도 X
          (random.nextDouble() - 0.5) * 10, // 속도 Y
        ),
        controller: _controller,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Color(0xFFFF5252), // 빨강
      Color(0xFF4CAF50), // 초록
      Color(0xFF2196F3), // 파랑
      Color(0xFFFFC107), // 노랑
      Color(0xFF9C27B0), // 보라
      Color(0xFFFF9800), // 주황
      Color(0xFF795548), // 갈색
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
        _selectedRestaurant =
            widget.restaurants[Random().nextInt(widget.restaurants.length)];
        _isSpinning = false;
      });

      _resultController.forward(from: 0.0); // 결과 카드 애니메이션 시작!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Transform.translate(
        offset: Offset(0, -60), // y축 -값이면 위로 올라감 (예: -50 픽셀 위로)
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
                  _isSpinning ? '뽑기 중...' : '뽑기 시작',
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildResultCard(),
                  ),
                ),
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
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          '${ball.id + 1}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.background.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RestaurantDetailScreen(
                        restaurantId: _selectedRestaurant!.kakaoPlaceId,
                      ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 이미지
                Positioned.fill(
                  child:
                      _selectedRestaurant!.restaurantImages != null &&
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

                // 텍스트 오버레이
                Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedRestaurant!.placeName ?? '맛집',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _selectedRestaurant!.distance != null
                                ? formatDistance(_selectedRestaurant!.distance!)
                                : '거리 정보 없음',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    _resultController.dispose();
    super.dispose();
  }
}

// 로또 공 클래스
class LotteryBall {
  final int id;
  final Color color;
  Offset position;
  Offset velocity;
  final AnimationController controller;

  LotteryBall({
    required this.id,
    required this.color,
    Offset? initialPosition,
    Offset? initialVelocity,
    required this.controller,
  }) : position = initialPosition ?? Offset.zero,
       velocity = initialVelocity ?? Offset.zero {
    controller.addListener(_updatePosition);
  }

  void _updatePosition() {
    // 다음 위치 계산
    position += velocity;

    // 화면 경계에서 튕기기 (반사)
    double maxX = 250; // 실제 화면 너비에 맞게 수정
    double maxY = 500; // 실제 화면 높이에 맞게 수정

    double dx = position.dx;
    double dy = position.dy;
    double vx = velocity.dx;
    double vy = velocity.dy;

    if (dx <= 0 || dx >= maxX) vx *= -1;
    if (dy <= 0 || dy >= maxY) vy *= -1;

    position = Offset(dx.clamp(0, maxX), dy.clamp(0, maxY));
    velocity = Offset(vx, vy);
  }
}
