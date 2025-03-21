import 'package:flutter/material.dart';
import '../../../services/review_service.dart';

/// "삭제 확인" 모달 창
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

                // ✅ 삭제 요청
                bool isDeleted = await ReviewService.deleteReview(parsedReviewId);

                Navigator.pop(context, isDeleted); // ✅ 삭제 성공 여부 반환
              } catch (e) {
                print("❌ 삭제 오류: $e");
                Navigator.pop(context, false); // ❌ 삭제 실패
              }
            },
          ),
        ],
      );
    },
  );
}
