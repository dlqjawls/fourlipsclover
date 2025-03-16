package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.exception.ReviewNotFoundException;
import com.patriot.fourlipsclover.exception.UserNotFoundException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberJpaRepository;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.mapper.ReviewMapper;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
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
}
