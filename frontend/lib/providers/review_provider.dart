import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final Map<String, Review> _reviews = {};

  void toggleLike(String reviewId, String likeStatus) {
    final review = _reviews[reviewId];
    if (review != null) {
      if (likeStatus == 'LIKE') {
        review.isLiked = !review.isLiked;
        review.likes += review.isLiked ? 1 : -1;
      } else {
        review.isDisliked = !review.isDisliked;
        review.dislikes += review.isDisliked ? 1 : -1;
      }
      notifyListeners();
    }
  }

  void updateReview(String id, Review updated) {
    _reviews[id] = updated;
    notifyListeners();
  }

  Review? getReview(String id) => _reviews[id];
}
