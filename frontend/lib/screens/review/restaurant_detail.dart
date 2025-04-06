import 'package:flutter/material.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:frontend/widgets/clover_loading_spinner.dart';
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
  late Future<RestaurantResponse> restaurantData;
  late Future<List<Review>> reviews;
  bool isFavorite = false;
  String? representativeImageUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final safeRestaurantId = widget.restaurantId;
    restaurantData = RestaurantService.fetchRestaurantDetails(safeRestaurantId);
    reviews = ReviewService.fetchReviews(safeRestaurantId);

    reviews.then((reviewList) {
      final imageUrl = getRepresentativeImage(reviewList);
      setState(() {
        representativeImageUrl = imageUrl;
      });
    });
  }

  String? getRepresentativeImage(List<Review> reviews) {
    final withImages = reviews.where((r) => r.imageUrl != null && r.imageUrl!.isNotEmpty).toList();
    if (withImages.isEmpty) return null;

    withImages.sort((a, b) {
      final likeCompare = b.likes.compareTo(a.likes);
      return likeCompare != 0 ? likeCompare : b.date.compareTo(a.date);
    });

    return withImages.first.imageUrl;
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RestaurantResponse>(
      future: restaurantData,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return LoadingOverlay(
          isLoading: isLoading,
          overlayColor: Colors.white.withOpacity(0.7),
          minDisplayTime: const Duration(milliseconds: 1200),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                snapshot.data?.placeName ?? "가게 정보",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            body: snapshot.hasError || snapshot.data == null
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "가게 정보를 불러오는 중 오류가 발생했습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestaurantInfo(
                    data: snapshot.data!,
                    imageUrl: representativeImageUrl,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Divider(thickness: 6.5, color: AppColors.verylightGray, height: 24),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Text("메뉴", style: TextStyle(fontSize: 16)),
                  ),
                  if ((snapshot.data!.menu ?? []).isNotEmpty)
                    MenuList(menu: snapshot.data!.menu!)
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("메뉴 정보가 없습니다."),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Divider(thickness: 6.5, color: AppColors.verylightGray, height: 24),
                  ),
                  ReviewList(
                    restaurantId: widget.restaurantId,
                    onReviewUpdated: fetchData,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
