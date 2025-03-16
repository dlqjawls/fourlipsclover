package com.patriot.fourlipsclover.restaurant.service;

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

@Service
@RequiredArgsConstructor
public class RestaurantService {

	private final RestaurantJpaRepository restaurantRepository;
	private final MemberJpaRepository memberRepository;
	private final ReviewMapper reviewMapper;
	private final ReviewJpaRepository reviewRepository;

	public ReviewResponse create(ReviewCreate reviewCreate) {
		Restaurant restaurant = restaurantRepository.findByKakaoPlaceId(
				reviewCreate.getKakaoPlaceId());

		Member reviewer = memberRepository.findById(reviewCreate.getMemberId()).orElseThrow();

		Review review = Review.builder().member(reviewer).content(reviewCreate.getContent())
				.restaurant(restaurant).createdAt(
						LocalDateTime.now()).isDelete(false).visitedAt(reviewCreate.getVisitedAt())
				.build();

		return reviewMapper.toDto(reviewRepository.save(review));
	}
}
