import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/review_model.dart';
import '../review_write.dart';
import 'delete_confirmation_modal.dart';

/// ✅ "수정 / 삭제" 작은 박스로 점 3개 아이콘 아래 표시
Future<dynamic> showReviewOptionsModal(BuildContext context, Review review, String restaurantId, Offset position) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  return await showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(position, position), // 점 3개 아이콘 아래 위치
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.edit, color: AppColors.primary),
          title: Text("수정"),
          onTap: () async {
            Navigator.pop(context); // 모달 닫기
            final updatedReview = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewWriteScreen(
                  kakaoPlaceId: restaurantId, // ✅ restaurantId 추가
                  review: review, // ✅ 기존 리뷰 데이터 전달
                ),
              ),
            );
            Navigator.pop(context, updatedReview); // ✅ 수정된 리뷰를 반환
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.redAccent),
          title: Text("삭제"),
          onTap: () {
            Navigator.pop(context); // 모달 닫기
            showDeleteConfirmationModal(context, review.id).then((result) {
              if (result == true) {
                Navigator.pop(context, true); // ✅ 삭제 완료 반환
              }
            });
          },
        ),
      ),
    ],
  );
}
