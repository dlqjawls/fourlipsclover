import 'package:flutter/material.dart';
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
  late Review _review;
  Offset? tapPosition;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  /// ✅ 리뷰 수정 후 UI 갱신
  Future<void> _editReview() async {
    final updatedReview = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewWriteScreen(
          review: _review,
          kakaoPlaceId: widget.restaurantId,
        ),
      ),
    );

    if (updatedReview != null && updatedReview is Review) {
      setState(() {
        _review = updatedReview;
      });
    }
  }

  /// ✅ 리뷰 삭제 처리
  void _deleteReview() {
    showDeleteConfirmationModal(context, _review.id).then((result) {
      if (result == true) {
        Navigator.pop(context, true);
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

                  /// ✅ 점 3개 아이콘 (수정 & 삭제 옵션)
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      tapPosition = details.globalPosition;
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
                              _deleteReview();
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ✅ 프로필 + 닉네임 + 방문 횟수 & 방문 날짜
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      _review.profileImageUrl ?? 'assets/default_profile.png',
                    ),
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

              /// ✅ 리뷰 이미지 표시 (사용자 이미지 없으면 기본 이미지 중 하나 선택)
              _buildReviewImage(_review.imageUrl, int.parse(_review.id)),

              const SizedBox(height: 12),

              /// ✅ 리뷰 내용
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

  /// ✅ 리뷰 이미지 하나만 표시 (사용자가 업로드한 이미지 없을 경우 기본 이미지 중 하나 선택)
  Widget _buildReviewImage(String? imageUrl, int reviewId) {
    List<String> defaultImages = [
      "assets/images/review_image.jpg",
      "assets/images/review_image2.jpg",
      "assets/images/review_image3.jpg"
    ];

    String selectedImage;

    // ✅ 사용자가 업로드한 이미지가 있을 경우 그대로 사용
    if (imageUrl != null && imageUrl.isNotEmpty) {
      selectedImage = imageUrl;
    } else {
      // ✅ 업로드된 이미지가 없으면 기본 이미지 중 하나를 순서대로 선택
      int imageIndex = reviewId % defaultImages.length; // 0, 1, 2 순환
      selectedImage = defaultImages[imageIndex];
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: selectedImage.startsWith("http") ? NetworkImage(selectedImage) : AssetImage(selectedImage) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// ✅ 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
