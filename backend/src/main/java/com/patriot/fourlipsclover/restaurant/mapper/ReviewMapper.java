package com.patriot.fourlipsclover.restaurant.mapper;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.payment.repository.VisitPaymentRepository;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewMemberResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewRestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.Review;

import java.time.LocalDateTime;
import java.util.List;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ReviewMapper {

	private final VisitPaymentRepository visitPaymentRepository;

	private ReviewRestaurantResponse toRestaurantResponse(Restaurant restaurant) {
		return ReviewRestaurantResponse.builder().restaurantId(restaurant.getRestaurantId())
				.addressName(restaurant.getAddressName())
				.category(restaurant.getCategory()).categoryName(restaurant.getCategoryName())
				.kakaoPlaceId(restaurant.getKakaoPlaceId())
				.roadAddressName(restaurant.getRoadAddressName())
				.build();
	}

	private ReviewMemberResponse toReviewer(Member member) {
		return ReviewMemberResponse.builder().email(member.getEmail())
				.memberId(member.getMemberId()).nickname(member.getNickname()).profileImageUrl(
						member.getProfileUrl())
				.build();
	}

	public Review toEntity(ReviewCreate dto, Restaurant restaurant, Member member) {
		return Review.builder()
				.content(dto.getContent())
				.restaurant(restaurant)
				.member(member)
				.visitedAt(dto.getVisitedAt())
				.isDelete(false)
				.createdAt(LocalDateTime.now())
				.build();
	}

	public ReviewResponse toDto(Review entity) {
		return ReviewResponse.builder()
				.reviewId(entity.getReviewId())
				.content(entity.getContent())
				.restaurant(toRestaurantResponse(entity.getRestaurant()))
				.reviewer(toReviewer(entity.getMember()))
				.visitedAt(entity.getVisitedAt())
				.createdAt(entity.getCreatedAt())
				.updatedAt(entity.getUpdatedAt())
				.build();
	}

	public ReviewResponse toReviewImageDto(Review entity, List<String> imageUrls) {
		return ReviewResponse.builder()
				.reviewId(entity.getReviewId())
				.content(entity.getContent())
				.restaurant(toRestaurantResponse(entity.getRestaurant()))
				.reviewer(toReviewer(entity.getMember()))
				.visitedAt(entity.getVisitedAt())
				.createdAt(entity.getCreatedAt())
				.updatedAt(entity.getUpdatedAt())
				.reviewImageUrls(imageUrls)
				.build();
	}
}