package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLike;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLikePK;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewLikeJpaRepository extends JpaRepository<ReviewLike, ReviewLikePK> {

	ReviewLike review(Review review);

	Long countByIdReviewIdAndLikeStatus(Integer reviewId, LikeStatus likeStatus);

	boolean existsByReviewAndMemberAndLikeStatus(Review review, Member member,
			LikeStatus likeStatus);

	int countByMember_MemberIdAndLikeStatus(Long memberId, LikeStatus likeStatus);
}
