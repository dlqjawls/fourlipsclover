import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_write.dart';
import 'widgets/review_options_modal.dart';
import 'widgets/delete_confirmation_modal.dart';
import '../../services/review_service.dart'; // ✅ 좋아요 기능을 위해 추가
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 토큰 가져오기 위해 필요

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
  String? accessToken;
  int memberId = 0; // ✅ 실제 로그인한 사용자 ID

  @override
  void initState() {
    super.initState();
    _review = widget.review;
    _loadAuthInfo();
  }

  Future<void> _loadAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("jwtToken");
    final userIdStr = prefs.getString("userId");
    final parsedId = int.tryParse(userIdStr ?? '');

    print("🪪 저장된 userId: $userIdStr → int 변환: $parsedId");

    setState(() {
      accessToken = token;
      memberId = parsedId ?? 0;
    });
  }


  Future<void> _toggleLike(String likeStatus) async {
    try {
      final message = await ReviewService.toggleLikeStatus(
        reviewId: int.parse(_review.id),
        memberId: memberId,
        likeStatus: likeStatus,
        accessToken: accessToken!,
      );
      print("✅ 서버 응답: $message");

      setState(() {
        if (likeStatus == "LIKE") {
          _review.isLiked = !_review.isLiked;
          _review.likes += _review.isLiked ? 1 : -1;
        } else {
          _review.isDisliked = !_review.isDisliked;
          _review.dislikes += _review.isDisliked ? 1 : -1;
        }
      });
    } catch (e) {
      print("❌ 좋아요/싫어요 처리 오류: $e");
    }
  }


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

              /// ✅ 프로필 + 유저명 + 방문 정보 + 좋아요
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _buildProfileImageProvider(_review.profileImageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_review.username, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 4),
                        Text(
                          "${_review.visitCount}번째 방문 | ${_formatDate(_review.date)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          size: 18,
                          color: _review.isLiked ? AppColors.primary : AppColors.lightGray,
                        ),
                        onPressed: () => _toggleLike("LIKE"),
                      ),
                      Text('${_review.likes}', style: TextStyle(fontSize: 12)),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          size: 18,
                          color: _review.isDisliked ? AppColors.primary : AppColors.lightGray,
                        ),
                        onPressed: () => _toggleLike("DISLIKE"),
                      ),
                      Text('${_review.dislikes}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 12),

              /// ✅ 리뷰 이미지 표시
              _buildReviewImage(_review.imageUrl, int.parse(_review.id)),

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

  ImageProvider _buildProfileImageProvider(String? imageUrl) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://your-api.com';

    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/default_profile.png');
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      return NetworkImage('$baseUrl/uploads/profile/$imageUrl');
    }
  }

  Widget _buildReviewImage(String? imageUrl, int reviewId) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://your-api.com';

    List<String> defaultImages = [
      "assets/images/review_image.jpg",
      "assets/images/review_image2.jpg",
      "assets/images/review_image3.jpg"
    ];

    String selectedImage;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
        selectedImage = '$baseUrl/uploads/review/$imageUrl';
      } else {
        selectedImage = imageUrl;
      }
    } else {
      int imageIndex = reviewId % defaultImages.length;
      selectedImage = defaultImages[imageIndex];
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: selectedImage.startsWith("http")
              ? NetworkImage(selectedImage)
              : AssetImage(selectedImage) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
