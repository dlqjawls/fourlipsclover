package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.exception.DeletedResourceAccessException;
import com.patriot.fourlipsclover.exception.ReviewNotFoundException;
import com.patriot.fourlipsclover.exception.UnauthorizedAccessException;
import com.patriot.fourlipsclover.exception.UserNotFoundException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberJpaRepository;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.mapper.ReviewMapper;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RestaurantService {

	private final RestaurantJpaRepository restaurantRepository;
	private final MemberJpaRepository memberRepository;
	private final ReviewMapper reviewMapper;
	private final ReviewJpaRepository reviewRepository;

	@Transactional
	public ReviewResponse create(ReviewCreate reviewCreate) {
		Restaurant restaurant = restaurantRepository.findByKakaoPlaceId(
				reviewCreate.getKakaoPlaceId());

		Member reviewer = memberRepository.findById(reviewCreate.getMemberId())
				.orElseThrow(UserNotFoundException::new);

		Review review = Review.builder().member(reviewer).content(reviewCreate.getContent())
				.restaurant(restaurant).createdAt(
						LocalDateTime.now()).isDelete(false).visitedAt(reviewCreate.getVisitedAt())
				.build();

		return reviewMapper.toDto(reviewRepository.save(review));
	}

	@Transactional(readOnly = true)
	public ReviewResponse findById(Integer reviewId) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		return reviewMapper.toDto(review);
	}

	@Transactional(readOnly = true)
	public List<ReviewResponse> findByKakaoPlaceId(String kakaoPlaceId) {
		if (Objects.isNull(kakaoPlaceId) || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("올바른 kakaoPlaceId 값을 입력하세요.");
		}
		List<Review> reviews = reviewRepository.findByKakaoPlaceId(kakaoPlaceId);
		return reviews.stream().map(reviewMapper::toDto).toList();
	}

	@Transactional
	public ReviewResponse update(Integer reviewId,
			ReviewUpdate reviewUpdate) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		//TODO : 유저 로그인 후 autnentication 등록 구현 후에 주석 해제하기.
//		checkReviewerIsCurrentUser(review.getMember().getMemberId());
		if (review.getIsDelete()) {
			throw new DeletedResourceAccessException("삭제된 리뷰 데이터는 접근할 수 없습니다.");
		}

		review.setContent(reviewUpdate.getContent());
		review.setUpdatedAt(LocalDateTime.now());
		review.setVisitedAt(reviewUpdate.getVisitedAt());
		return reviewMapper.toDto(review);
	}

	private void checkReviewerIsCurrentUser(Integer reviewMemberId) {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentUsername = authentication.getName();
		Member currentMember = memberRepository.findByEmail(currentUsername)
				.orElseThrow(UserNotFoundException::new);
		if (!Objects.equals(currentMember.getMemberId(), reviewMemberId)) {
			throw new UnauthorizedAccessException("현재 User ID가 작성자 ID와 다릅니다.");
		}
	}
}
