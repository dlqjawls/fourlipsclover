import 'package:flutter/material.dart';

/// "삭제 확인" 모달 창
void showDeleteConfirmationModal(BuildContext context, String reviewId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("삭제하시겠습니까?"),
        content: Text("삭제된 리뷰는 복구할 수 없습니다."),
        actions: [
          TextButton(
            child: Text("아니오"),
            onPressed: () {
              Navigator.pop(context); // 모달 닫기
            },
          ),
          TextButton(
            child: Text("예", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              // 삭제 로직 (API 연동)
              print("리뷰 삭제 완료: $reviewId");
              Navigator.pop(context); // 삭제 확인 모달 닫기
              Navigator.pop(context); // 리뷰 상세 페이지 닫기
            },
          ),
        ],
      );
    },
  );
}
