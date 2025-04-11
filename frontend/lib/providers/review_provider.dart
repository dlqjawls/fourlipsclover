import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final Map<String, Review> _reviews = {};

  void toggleLike(String reviewId, String likeStatus) {
    final review = _reviews[reviewId];
    if (review != null) {
      if (likeStatus == 'LIKE') {
        if (!review.isLiked) {
          // 좋아요를 누른 상태로 변경
          review.isLiked = true;
          review.likes += 1;

          // 싫어요 상태였으면 해제
          if (review.isDisliked) {
            review.isDisliked = false;
            review.dislikes = (review.dislikes > 0) ? review.dislikes - 1 : 0;
          }
        } else {
          // 이미 눌려있으면 해제
          review.isLiked = false;
          review.likes = (review.likes > 0) ? review.likes - 1 : 0;
        }
      } else if (likeStatus == 'DISLIKE') {
        if (!review.isDisliked) {
          // 싫어요를 누른 상태로 변경
          review.isDisliked = true;
          review.dislikes += 1;

          // 좋아요 상태였으면 해제
          if (review.isLiked) {
            review.isLiked = false;
            review.likes = (review.likes > 0) ? review.likes - 1 : 0;
          }
        } else {
          // 이미 눌려있으면 해제
          review.isDisliked = false;
          review.dislikes = (review.dislikes > 0) ? review.dislikes - 1 : 0;
        }
      }

      notifyListeners();
    }
  }

  void updateReview(String id, Review updated) {
    _reviews[id] = updated;
    notifyListeners();
  }

  void setReviews(List<Review> reviews) {
    _reviews.clear();
    for (var review in reviews) {
      _reviews[review.id] = review;
    }
    notifyListeners();
  }

  Review? getReview(String id) => _reviews[id];
}
