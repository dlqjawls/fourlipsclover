import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import '../../../models/review_model.dart';
import '../review_write.dart';
import 'delete_confirmation_modal.dart';

/// ✅ "수정 / 삭제" 작은 박스로 점 3개 아이콘 아래 표시
void showReviewOptionsModal(BuildContext context, Review review, Offset position) {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
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
          onTap: () {
            Navigator.pop(context); // 모달 닫기
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewWriteScreen(review: review), // 수정 페이지 이동
              ),
            );
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.redAccent),
          title: Text("삭제"),
          onTap: () {
            Navigator.pop(context); // 모달 닫기
            showDeleteConfirmationModal(context, review.id); // 삭제 확인 모달 실행
          },
        ),
      ),
    ],
  );
}
