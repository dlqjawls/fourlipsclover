import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/review_service.dart';
import '../../../providers/app_provider.dart';

Future<bool?> showDeleteConfirmationModal(BuildContext context, String reviewId) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("삭제하시겠습니까?"),
        content: Text("삭제된 리뷰는 복구할 수 없습니다."),
        actions: [
          TextButton(
            child: Text("아니오"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          TextButton(
            child: Text("예", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              try {
                int parsedReviewId = int.tryParse(reviewId) ?? -1;
                if (parsedReviewId == -1) {
                  throw Exception("유효하지 않은 reviewId: $reviewId");
                }

                final accessToken = Provider.of<AppProvider>(context, listen: false).jwtToken;
                if (accessToken == null) throw Exception("토큰 없음");

                bool isDeleted = await ReviewService.deleteReview(
                  reviewId: parsedReviewId,
                  accessToken: accessToken,
                );

                Navigator.pop(context, isDeleted);
              } catch (e) {
                print("❌ 삭제 오류: $e");
                Navigator.pop(context, false);
              }
            },
          ),
        ],
      );
    },
  );
}
