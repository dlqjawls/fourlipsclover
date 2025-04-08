import 'package:flutter/material.dart';
import '../screens/review/review_write.dart';
import '../models/review_model.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

Future<Review?> showReviewBottomSheet({
  required BuildContext context,
  required String kakaoPlaceId,
  Review? review,
}) {
  final appProvider = Provider.of<AppProvider>(context, listen: false);
  return showModalBottomSheet<Review>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ChangeNotifierProvider<AppProvider>.value(
        value: appProvider,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: ReviewWriteScreen(
                kakaoPlaceId: kakaoPlaceId,
                review: review,
                scrollController: scrollController,
              ),
            );
          },
        ),
      );
    },
  );
}