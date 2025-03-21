import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_write.dart';
import 'widgets/review_options_modal.dart';
import 'widgets/delete_confirmation_modal.dart';

class ReviewDetail extends StatefulWidget {
  final Review review;
  final String restaurantId;

  const ReviewDetail({Key? key, required this.review, required this.restaurantId}) : super(key: key);

  @override
  _ReviewDetailState createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  late Review _review; // ✅ 수정된 리뷰를 저장할 변수
  Offset? tapPosition;

  @override
  void initState() {
    super.initState();
    _review = widget.review; // ✅ 초기 리뷰 데이터 설정
  }

  /// ✅ 리뷰 수정 후 UI 갱신
  Future<void> _editReview() async {
    final updatedReview = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewWriteScreen(
          review: _review, // ✅ 현재 리뷰 정보 전달
          kakaoPlaceId: widget.restaurantId,
        ),
      ),
    );

    if (updatedReview != null && updatedReview is Review) {
      setState(() {
        _review = updatedReview; // ✅ 수정된 리뷰를 반영
      });
    }
  }

  /// ✅ 리뷰 삭제 처리
  void _deleteReview() {
    showDeleteConfirmationModal(context, _review.id).then((result) {
      if (result == true) {
        Navigator.pop(context, true); // ✅ 삭제 성공 시 이전 화면으로 돌아가면서 리스트 갱신
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("리뷰 상세"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ 리뷰 제목 + 점 3개 아이콘 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_review.title != null && _review.title!.isNotEmpty)
                    Expanded(
                      child: Text(
                        _review.title!,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  /// ✅ 점 3개 아이콘 (오른쪽 정렬)
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      tapPosition = details.globalPosition; // ✅ 클릭 위치 저장
                    },
                    child: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {
                        if (tapPosition != null) {
                          showReviewOptionsModal(
                            context,
                            _review,
                            widget.restaurantId,
                            tapPosition!,
                          ).then((result) {
                            if (result == true) {
                              _deleteReview(); // ✅ 삭제된 경우 삭제 모달 실행
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 프로필 + 닉네임 + 방문 횟수 & 방문 날짜
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_review.profileImageUrl ?? 'assets/default_profile.png'),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _review.username,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    "${_review.visitCount}번째 방문 | ${_formatDate(_review.date)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Divider(color: Colors.grey[300], thickness: 1),

              const SizedBox(height: 12),

              _buildReviewImage(_review.imageUrl),

              const SizedBox(height: 12),

              Text(
                _review.content,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        image: (imageUrl != null && imageUrl.isNotEmpty)
            ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
