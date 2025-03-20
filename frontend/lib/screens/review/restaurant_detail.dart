import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/restaurant_service.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';
import 'restaurant_info.dart';
import 'widgets/menu_list.dart';
import 'review_list.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<Map<String, dynamic>> restaurantData;
  late Future<List<Review>> reviews;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    restaurantData = RestaurantService.fetchRestaurantDetails(widget.restaurantId);
    reviews = ReviewService.fetchReviews(widget.restaurantId);
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: restaurantData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(data['name'] ?? "가게 정보"),
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, "/home");
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleFavorite,
                ),
                SizedBox(width: 20),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 가게 정보
                  RestaurantInfo(data: data),

                  /// 메뉴 목록
                  MenuList(menu: data['menu']),

                  /// 리뷰 목록
                  ReviewList(reviews: reviews),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
