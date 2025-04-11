import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/review_model.dart';
import '../review_write.dart';
import 'delete_confirmation_modal.dart';
import '../../../utils/review_utils.dart'; // ✅ 바텀시트 함수 임포트

/// ✅ 리뷰 수정/삭제 팝업 - 점 3개 누르면 뜨는 작은 메뉴
Future<void> showReviewOptionsModal({
  required BuildContext context,
  required Review review,
  required String kakaoPlaceId,
  required Offset position,
  required VoidCallback onReviewUpdated, // ✅ 리스트 갱신 콜백
}) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  await showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.edit, color: AppColors.primary),
          title: Text("수정"),
          onTap: () async {
            Navigator.pop(context); // 메뉴 닫기

            final updatedReview = await showReviewBottomSheet(
              context: context,
              kakaoPlaceId: kakaoPlaceId,
              review: review,
            );

            if (updatedReview != null) {
              onReviewUpdated(); // ✅ 리스트 갱신
            }
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.redAccent),
          title: Text("삭제"),
          onTap: () async {
            Navigator.pop(context); // 메뉴 닫기

            final deleted = await showDeleteConfirmationModal(context, review.id);
            if (deleted == true) {
              onReviewUpdated(); // ✅ 리스트 갱신
            }
          },
        ),
      ),
    ],
    // ✅ 커스텀 테마 적용 (라운드 + 투명도)
    color: Colors.white.withOpacity(0.86),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // 라운드 크게
    ),
  );
}
