package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.exception.DeletedResourceAccessException;
import com.patriot.fourlipsclover.exception.InvalidDataException;
import com.patriot.fourlipsclover.exception.ReviewNotFoundException;
import com.patriot.fourlipsclover.exception.UnauthorizedAccessException;
import com.patriot.fourlipsclover.exception.UserNotFoundException;
import com.patriot.fourlipsclover.image.service.ReviewImageService;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberJpaRepository;
import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLike;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLikePK;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantMapper;
import com.patriot.fourlipsclover.restaurant.mapper.ReviewMapper;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewLikeJpaRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class RestaurantService {

	private final RestaurantJpaRepository restaurantRepository;
	private final ReviewLikeJpaRepository reviewLikeJpaRepository;
	private final MemberJpaRepository memberRepository;
	private final ReviewMapper reviewMapper;
	private final RestaurantMapper restaurantMapper;
	private final ReviewJpaRepository reviewRepository;
	private final ReviewImageService reviewImageService;

	@Transactional
	public ReviewResponse create(ReviewCreate reviewCreate, List<MultipartFile> images) {
		Restaurant restaurant = restaurantRepository.findByKakaoPlaceId(
				reviewCreate.getKakaoPlaceId()).orElseThrow();

		Member reviewer = memberRepository.findById(reviewCreate.getMemberId())
				.orElseThrow(UserNotFoundException::new);

		Review review = Review.builder().member(reviewer).content(reviewCreate.getContent())
				.restaurant(restaurant).createdAt(
						LocalDateTime.now()).isDelete(false).visitedAt(reviewCreate.getVisitedAt())
				.build();

		reviewRepository.save(review);
		List<String> imageUrls = reviewImageService.uploadFiles(review, images);

		return reviewMapper.toReviewImageDto(review, imageUrls);
	}

	@Transactional(readOnly = true)
	public ReviewResponse findById(Integer reviewId) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		List<String> imageUrls = reviewImageService.getImageUrlsByReviewId(reviewId);

		return reviewMapper.toReviewImageDto(review, imageUrls);
	}

	@Transactional(readOnly = true)
	public List<ReviewResponse> findByKakaoPlaceId(String kakaoPlaceId) {
		if (Objects.isNull(kakaoPlaceId) || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("올바른 kakaoPlaceId 값을 입력하세요.");
		}
		List<Review> reviews = reviewRepository.findByKakaoPlaceId(kakaoPlaceId);
		return reviews.stream()
				.map(review -> {
					List<String> imageUrls = reviewImageService.getImageUrlsByReviewId(
							review.getReviewId());
					return reviewMapper.toReviewImageDto(review, imageUrls);
				})
				.toList();
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
		// AOP로 분리해서 controller에서
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentUsername = authentication.getName();
		Member currentMember = memberRepository.findByEmail(currentUsername)
				.orElseThrow(UserNotFoundException::new);
		if (!Objects.equals(currentMember.getMemberId(), reviewMemberId)) {
			throw new UnauthorizedAccessException("현재 User ID가 작성자 ID와 다릅니다.");
		}
	}

	@Transactional
	public ReviewDeleteResponse delete(Integer reviewId) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		if (review.getIsDelete()) {
			throw new DeletedResourceAccessException("이미 삭제된 리뷰입니다.");
		}
		//TODO : 유저 로그인 후 autnentication 등록 구현 후에 주석 해제하기.
//		checkReviewerIsCurrentUser(review.getMember().getMemberId());
		review.setIsDelete(true);
		review.setDeletedAt(LocalDateTime.now());
		reviewRepository.save(review);
		return new ReviewDeleteResponse("리뷰를 삭제하였습니다.", reviewId);
	}

	@Transactional(readOnly = true)
	public RestaurantResponse findRestaurantByKakaoPlaceId(String kakaoPlaceId) {
		if (Objects.isNull(kakaoPlaceId) || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("올바른 kakaoPlaceId 값을 입력하세요.");
		}
		return restaurantMapper.toDto(
				restaurantRepository.findByKakaoPlaceId(kakaoPlaceId)
						.orElseThrow(() -> new InvalidDataException(
								"존재 하지 않는 식당입니다.")));
	}

	@Transactional(readOnly = true)
	public List<RestaurantResponse> findNearbyRestaurants(Double latitude, Double longitude,
			Integer radius) {

		List<Restaurant> nearbyRestaurants = restaurantRepository.findNearbyRestaurants(
				latitude, longitude, radius);
		return nearbyRestaurants.stream()
				.map(restaurantMapper::toDto)
				.collect(Collectors.toList());
	}

	@Transactional
	public String like(Integer reviewId, ReviewLikeCreate request) {
		Member likedMember = memberRepository.findById(request.getMemberId())
				.orElseThrow(UserNotFoundException::new);
		Review likedReview = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));

		if (likedMember.getMemberId() == likedReview.getMember().getMemberId()) {
			throw new InvalidDataException("작성자는 본인 글에 좋아요/싫어요를 생성할 수 없습니다.");
		}
		final String[] result = new String[1];

		ReviewLikePK id = ReviewLikePK.builder().reviewId(reviewId)
				.memberId(request.getMemberId()).build();
		reviewLikeJpaRepository.findById(id).ifPresentOrElse(
				existsReviewLike -> {
					if (request.getLikeStatus().equals(existsReviewLike.getLikeStatus())) {
						reviewLikeJpaRepository.delete(existsReviewLike);
						result[0] =
								(request.getLikeStatus().equals(LikeStatus.LIKE)) ? "좋아요를 취소했습니다"
										: "싫어요를 취소했습니다";
					} else {
						existsReviewLike.setLikeStatus(request.getLikeStatus());
						reviewLikeJpaRepository.save(existsReviewLike);
						result[0] =
								(request.getLikeStatus().equals(LikeStatus.LIKE)) ? "좋아요로 변경했습니다"
										: "싫어요로 변경했습니다";
					}
				},
				() -> {
					ReviewLike reviewLike = ReviewLike.builder().id(id)
							.likeStatus(request.getLikeStatus())
							.review(likedReview).member(likedMember).build();
					reviewLikeJpaRepository.save(reviewLike);
					result[0] = (request.getLikeStatus().equals(LikeStatus.LIKE)) ? "좋아요를 했습니다"
							: "싫어요를 했습니다";
				}
		);
		return result[0];
	}
}
