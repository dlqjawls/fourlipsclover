import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/config/theme.dart';
import '../../models/review_model.dart';
import '../review/review_write.dart';
import 'widgets/delete_confirmation_modal.dart';
import '../../services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewDetail extends StatefulWidget {
  final Review review;
  final String kakaoPlaceId;

  const ReviewDetail({Key? key, required this.review, required this.kakaoPlaceId}) : super(key: key);

  @override
  _ReviewDetailState createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  late Review _review;
  String? accessToken;
  int memberId = 0;
  bool _isUpdated = false; // ✅ 수정 여부

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
          kakaoPlaceId: widget.kakaoPlaceId,
        ),
      ),
    );

    if (updatedReview != null && updatedReview is Review) {
      setState(() {
        _review = updatedReview;
        _isUpdated = true; // ✅ 수정됨 표시
      });
    }
  }

  void _deleteReview() {
    showDeleteConfirmationModal(context, _review.id).then((result) {
      if (result == true) {
        Navigator.pop(context, true); // ✅ 삭제 후 갱신
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _isUpdated); // ✅ 수정됐으면 true 넘김
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("리뷰 상세"),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            if (_review.memberId == memberId)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await _editReview();
                  } else if (value == 'delete') {
                    _deleteReview();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: AppColors.primary),
                      title: Text("수정"),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.redAccent),
                      title: Text("삭제"),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.black),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    // 이미지 없으면 아무것도 렌더링하지 않음
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink(); // 👈 완전 빈 위젯 반환
    }

    String fullUrl;
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
      fullUrl = '$baseUrl/uploads/review/$imageUrl';
    } else {
      fullUrl = imageUrl;
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: fullUrl.startsWith("http")
              ? NetworkImage(fullUrl)
              : AssetImage(fullUrl) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }
}
