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
    fetchData();
  }

  void fetchData() {
    final safeRestaurantId = widget.restaurantId.isNotEmpty ? widget.restaurantId : "1605310387";
    setState(() {
      restaurantData = RestaurantService.fetchRestaurantDetails(safeRestaurantId);
      reviews = ReviewService.fetchReviews(safeRestaurantId);
    });
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("가게 정보를 불러오는 중 오류가 발생했습니다.", style: TextStyle(fontSize: 16, color: Colors.red)),
              ),
            );
          }

          final data = snapshot.data!;
          final menu = data['menu'] ?? [];
          print("✅ 가게 데이터: $data");

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true, // ✅ 제목 완전 중앙 정렬
              title: Text(
                data['placeName'] ?? "가게 정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                const SizedBox(width: 20),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestaurantInfo(data: data),

                  /// ✅ 메뉴 리스트 (menu가 없으면 빈 리스트로 대체)
                  if (menu.isNotEmpty)
                    MenuList(menu: menu)
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("메뉴 정보가 없습니다.", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                    ),

                  /// ✅ 리뷰 목록 (리뷰 작성 후 화면 갱신 기능 추가)
                  ReviewList(
                    restaurantId: widget.restaurantId,
                    reviews: reviews,
                    onReviewUpdated: fetchData,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
