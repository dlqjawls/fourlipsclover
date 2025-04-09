package com.patriot.fourlipsclover.restaurant.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.exception.DeletedResourceAccessException;
import com.patriot.fourlipsclover.exception.InvalidDataException;
import com.patriot.fourlipsclover.exception.ReviewNotFoundException;
import com.patriot.fourlipsclover.exception.UnauthorizedAccessException;
import com.patriot.fourlipsclover.exception.UserNotFoundException;
import com.patriot.fourlipsclover.image.service.ReviewImageService;
import com.patriot.fourlipsclover.locals.mapper.LocalCertificationMapper;
import com.patriot.fourlipsclover.locals.repository.LocalCertificationRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberJpaRepository;
import com.patriot.fourlipsclover.payment.entity.DataSource;
import com.patriot.fourlipsclover.payment.entity.VisitPayment;
import com.patriot.fourlipsclover.payment.repository.VisitPaymentRepository;
import com.patriot.fourlipsclover.restaurant.dto.kafka.RestaurantKafkaDto;
import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewSentimentResponse;
import com.patriot.fourlipsclover.restaurant.entity.City;
import com.patriot.fourlipsclover.restaurant.entity.FoodCategory;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLike;
import com.patriot.fourlipsclover.restaurant.entity.ReviewLikePK;
import com.patriot.fourlipsclover.restaurant.entity.ReviewSentiment;
import com.patriot.fourlipsclover.restaurant.entity.SentimentStatus;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantMapper;
import com.patriot.fourlipsclover.restaurant.mapper.ReviewMapper;
import com.patriot.fourlipsclover.restaurant.repository.CityRepository;
import com.patriot.fourlipsclover.restaurant.repository.FoodCategoryRepository;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantImageRepository;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewLikeJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewSentimentRepository;
import com.patriot.fourlipsclover.tag.service.TagService;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;

@Slf4j
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
	private final CityRepository cityRepository;
	private final FoodCategoryRepository foodCategoryRepository;
	private final TagService tagService;
	private final RestaurantImageRepository restaurantImageRepository;
	private final WebClient webClient;
	private final ReviewSentimentRepository reviewSentimentRepository;
	private final VisitPaymentRepository visitPaymentRepository;
	private final LocalCertificationRepository localCertificationRepository;
	private final LocalCertificationMapper localCertificationMapper;
	@Value("${model.server.uri}")
	private String MODEL_SERVER_URI;

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
		CompletableFuture.runAsync(() -> tagService.generateTag(review));

		// 결제 정보 저장
		VisitPayment visitPayment = VisitPayment.builder()
				.restaurantId(restaurant)
				.userId(reviewer.getMemberId())
				.amount(reviewCreate.getAmount())
				.visitedPersonnel(reviewCreate.getVisitedPersonnel())
				.paidAt(reviewCreate.getPaidAt() != null ? reviewCreate.getPaidAt()
						: LocalDateTime.now())
				.dataSource(DataSource.member)
				.createdAt(LocalDateTime.now())
				.build();

		visitPaymentRepository.save(visitPayment);

		String reviewTextSentiment = analyzeSentiment(review);
		List<String> imageUrls = reviewImageService.uploadFiles(review, images);
		ReviewResponse response = reviewMapper.toReviewImageDto(review, imageUrls);
		localCertificationRepository.findByMember(reviewer).ifPresent(lc -> {
			response.setLocalCertificationResponse(localCertificationMapper.toDto(lc));
		});
		response.setLikedCount(0);
		response.setDislikedCount(0);
		return response;
	}

	public String analyzeSentiment(Review review) {
		Map<String, String> requestMap = new HashMap<>();
		requestMap.put("text", review.getContent());
		String requestBody = null;
		try {
			requestBody = new ObjectMapper().writeValueAsString(requestMap);
		} catch (JsonProcessingException e) {
			throw new RuntimeException(e);
		}
		ReviewSentimentResponse reviewSentimentResponse = webClient.post()
				.uri(MODEL_SERVER_URI + "/analyze")
				.contentType(
						MediaType.APPLICATION_JSON).bodyValue(requestBody).retrieve()
				.bodyToMono(
						ReviewSentimentResponse.class).block();
		ReviewSentiment reviewSentiment = new ReviewSentiment();
		reviewSentiment.setReview(review);
		reviewSentiment.setSentimentStatus(
				Objects.requireNonNull(reviewSentimentResponse).getSentiment().equals("긍정적") ?
						SentimentStatus.POSITIVE : SentimentStatus.NEGATIVE);
		reviewSentimentRepository.save(reviewSentiment);
		return reviewSentimentResponse.getSentiment();
	}

	@Transactional(readOnly = true)
	public ReviewResponse findById(Integer reviewId) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		Member reviewer = review.getMember();
		List<String> imageUrls = reviewImageService.getImageUrlsByReviewId(reviewId);
		ReviewResponse response = reviewMapper.toReviewImageDto(review, imageUrls);
		Long likedCount = reviewLikeJpaRepository.countByIdReviewIdAndLikeStatus(reviewId,
				LikeStatus.LIKE);
		Long dislikedCount = reviewLikeJpaRepository.countByIdReviewIdAndLikeStatus(reviewId,
				LikeStatus.DISLIKE);
		response.setLikedCount(likedCount.intValue());
		response.setDislikedCount(dislikedCount.intValue());
		Member member = loadCurrentMember();
		if (member != null) {
			boolean userLiked = reviewLikeJpaRepository.existsByReviewAndMemberAndLikeStatus(review,
					member, LikeStatus.LIKE);
			boolean userDisliked = reviewLikeJpaRepository.existsByReviewAndMemberAndLikeStatus(
					review, member, LikeStatus.DISLIKE);
			response.setUserLiked(userLiked);
			response.setUserDisliked(userDisliked);
		} else {
			response.setUserLiked(false);
			response.setUserDisliked(false);
		}
		localCertificationRepository.findByMember(reviewer).ifPresent(lc -> {
			response.setLocalCertificationResponse(localCertificationMapper.toDto(lc));
		});
		return response;
	}

	private Member loadCurrentMember() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (authentication == null || !authentication.isAuthenticated() ||
				"anonymousUser".equals(authentication.getPrincipal())) {
			return null;
		}
		CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
		return userDetails.getMember();
	}

	@Transactional(readOnly = true)
	public List<ReviewResponse> findByKakaoPlaceId(String kakaoPlaceId) {
		if (Objects.isNull(kakaoPlaceId) || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("올바른 kakaoPlaceId 값을 입력하세요.");
		}
		List<Review> reviews = reviewRepository.findByKakaoPlaceId(kakaoPlaceId);
		System.out.println(reviews);
		return reviews.stream()
				.map(review -> {
					Integer reviewId = review.getReviewId();
					List<String> imageUrls = reviewImageService.getImageUrlsByReviewId(reviewId);
					Member reviewer = review.getMember();
					ReviewResponse response = reviewMapper.toReviewImageDto(review, imageUrls);

					Long likedCount = reviewLikeJpaRepository.countByIdReviewIdAndLikeStatus(
							reviewId, LikeStatus.LIKE);
					Long dislikedCount = reviewLikeJpaRepository.countByIdReviewIdAndLikeStatus(
							reviewId, LikeStatus.DISLIKE);
					response.setLikedCount(likedCount.intValue());
					response.setDislikedCount(dislikedCount.intValue());
					Member member = loadCurrentMember();
					if (member != null) {
						boolean userLiked = reviewLikeJpaRepository.existsByReviewAndMemberAndLikeStatus(
								review, member, LikeStatus.LIKE);
						boolean userDisliked = reviewLikeJpaRepository.existsByReviewAndMemberAndLikeStatus(
								review, member, LikeStatus.DISLIKE);
						response.setUserLiked(userLiked);
						response.setUserDisliked(userDisliked);
					} else {
						response.setUserLiked(false);
						response.setUserDisliked(false);
					}
					localCertificationRepository.findByMember(reviewer).ifPresent(lc -> {
						response.setLocalCertificationResponse(localCertificationMapper.toDto(lc));
					});
					return response;
				})
				.toList();
	}

	@Transactional
	public ReviewResponse update(Integer reviewId,
			ReviewUpdate reviewUpdate, List<String> deleteImageUrls, List<MultipartFile> images) {
		Review review = reviewRepository.findById(reviewId)
				.orElseThrow(() -> new ReviewNotFoundException(reviewId));
		checkReviewerIsCurrentUser(review.getMember().getMemberId());
		if (review.getIsDelete()) {
			throw new DeletedResourceAccessException("삭제된 리뷰 데이터는 접근할 수 없습니다.");
		}

		if (deleteImageUrls != null && !deleteImageUrls.isEmpty()) {
			reviewImageService.deleteImages(deleteImageUrls);
		}

		if (images != null && !images.isEmpty()) {
			reviewImageService.uploadFiles(review, images);
		}

		review.setContent(reviewUpdate.getContent());
		review.setUpdatedAt(LocalDateTime.now());
		review.setVisitedAt(reviewUpdate.getVisitedAt());
		List<String> reviewUrls = reviewImageService.getImageUrlsByReviewId(reviewId);
		return reviewMapper.toReviewImageDto(review, reviewUrls);
	}

	private void checkReviewerIsCurrentUser(Long reviewMemberId) {
		Member member = loadCurrentMember();
		if (member == null) {
			throw new UnauthorizedAccessException("로그인이 필요한 기능입니다.");
		}
		if (!Objects.equals(member.getMemberId(), reviewMemberId)) {
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
		checkReviewerIsCurrentUser(review.getMember().getMemberId());
		review.setIsDelete(true);
		review.setDeletedAt(LocalDateTime.now());
		reviewRepository.save(review);
		return new ReviewDeleteResponse("리뷰를 삭제하였습니다.", reviewId);
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

	@Transactional
	public void processKafkaMessage(RestaurantKafkaDto dto) {
		// dto가 null인지 먼저 확인
		if (dto == null) {
			log.error("Restaurant DTO is null, cannot process Kafka message");
			return;
		}

		// 필수 ID 필드 검증
		if (dto.getRestaurantId() == null) {
			log.error("Restaurant ID is null, cannot process Kafka message");
			return;
		}

		log.info("Processing Kafka message for restaurant: {}", dto.getRestaurantId());

		// 기본값으로 "r" (read) 설정
		String operation = dto.getOp();
		if (operation == null) {
			operation = "r";
			log.info("Operation type is null, defaulting to 'r' (read)");
		}

		try {
			switch (operation) {
				case "c":
				case "r":
				case "u":
					saveOrUpdateFromKafka(dto);
					break;
				case "d":
					deleteFromKafka(dto);
					break;
				default:
					log.warn("Unknown operation type in Kafka message: {}", operation);
			}
		} catch (Exception e) {
			log.error("Error processing Kafka message for restaurant {}: {}",
					dto.getRestaurantId(), e.getMessage(), e);
		}
	}

	private void saveOrUpdateFromKafka(RestaurantKafkaDto dto) {
		Restaurant restaurant = restaurantRepository.findById(dto.getRestaurantId())
				.orElse(new Restaurant());

		// DTO에서 엔티티로 데이터 복사
		restaurant.setRestaurantId(dto.getRestaurantId());
		restaurant.setPlaceName(dto.getPlaceName());
		restaurant.setAddressName(dto.getAddressName());
		restaurant.setRoadAddressName(dto.getRoadAddressName());
		restaurant.setCategoryName(dto.getCategoryName());
		restaurant.setPhone(dto.getPhone());
		restaurant.setPlaceUrl(dto.getPlaceUrl());
		restaurant.setX(dto.getX());
		restaurant.setY(dto.getY());

		// 모든 필수 필드 검증
		if (dto.getRestaurantId() == null) {
			log.error("Cannot save restaurant with null ID");
			return;
		}

		if (dto.getFoodCategoryId() != null) {
			FoodCategory foodCategory = foodCategoryRepository.findById(dto.getFoodCategoryId())
					.orElse(null);
			restaurant.setFoodCategory(foodCategory);
		}
		// 연관 엔티티 설정 (City와 FoodCategory 레퍼런스를 찾아서 설정)
		if (dto.getCityId() != null) {
			City city = cityRepository.findById(dto.getCityId()).orElse(null);
			restaurant.setCity(city);
		}

		if (dto.getFoodCategoryId() != null) {
			FoodCategory foodCategory = foodCategoryRepository.findById(dto.getFoodCategoryId())
					.orElse(null);
			restaurant.setFoodCategory(foodCategory);
		}

		restaurantRepository.save(restaurant);
		log.info("Restaurant saved/updated from Kafka: {}", restaurant.getRestaurantId());
	}

	private void deleteFromKafka(RestaurantKafkaDto dto) {
		restaurantRepository.findById(dto.getRestaurantId()).ifPresent(restaurant -> {
			restaurantRepository.delete(restaurant);
			log.info("Restaurant deleted from Kafka: {}", dto.getRestaurantId());
		});
	}

	private String calculateAvgAmountJson(String kakaoPlaceId) {
		// 카카오 PlaceId로 레스토랑 찾기
		Restaurant restaurant = restaurantRepository.findByKakaoPlaceId(kakaoPlaceId)
				.orElseThrow(() -> new InvalidDataException("존재하지 않는 식당입니다."));

		// 찾은 레스토랑의 ID로 결제 데이터 조회
		List<VisitPayment> payments = visitPaymentRepository.findByRestaurantId_RestaurantId(restaurant.getRestaurantId());

		// 유효한 결제 데이터만 필터링
		List<VisitPayment> validPayments = payments.stream()
				.filter(payment ->
						payment.getVisitedPersonnel() != null &&
								payment.getVisitedPersonnel() > 0 &&
								payment.getAmount() != null &&
								payment.getAmount() > 0)
				.collect(Collectors.toList());

		// 1인당 결제 금액 계산
		List<Integer> perPersonAmounts = validPayments.stream()
				.map(payment -> payment.getAmount() / payment.getVisitedPersonnel())
				.collect(Collectors.toList());

		if (perPersonAmounts.isEmpty()) {
			return null;
		}

		// 가격대별 분포 계산
		Map<String, Integer> priceRangeDistribution = new LinkedHashMap<>();
		perPersonAmounts.forEach(amount -> {
			String range = calculatePriceRange(amount);
			priceRangeDistribution.merge(range, 1, Integer::sum);
		});

		// 평균 금액의 구간 계산
		String avgAmountRange = calculatePriceRange(
				(int) perPersonAmounts.stream()
						.mapToInt(Integer::intValue)
						.average()
						.orElse(0)
		);

		// 결과 맵 생성
		Map<String, Object> result = new LinkedHashMap<>();
		result.put("avg", avgAmountRange);

		// 분포 정보 추가
		priceRangeDistribution.forEach((key, value) -> {
			if (value > 0) {
				result.put(key, value);
			}
		});

		try {
			// JSON 문자열로 변환
			return new ObjectMapper().writeValueAsString(result);
		} catch (Exception e) {
			log.error("Error converting avg amount to JSON", e);
			return "{\"avg\": \"정보 없음\"}";
		}
	}

	private String calculatePriceRange(Integer amount) {
		if (amount <= 10000) {
			return "1 ~ 10000";
		}
		if (amount <= 20000) {
			return "10000 ~ 20000";
		}
		if (amount <= 30000) {
			return "20000 ~ 30000";
		}
		if (amount <= 40000) {
			return "30000 ~ 40000";
		}
		if (amount <= 50000) {
			return "40000 ~ 50000";
		}
		if (amount <= 60000) {
			return "50000 ~ 60000";
		}
		if (amount <= 70000) {
			return "60000 ~ 70000";
		}
		if (amount <= 80000) {
			return "70000 ~ 80000";
		}
		if (amount <= 90000) {
			return "80000 ~ 90000";
		}
		if (amount <= 100000) {
			return "90000 ~ 100000";
		}
		return "100000 ~";
	}

}
