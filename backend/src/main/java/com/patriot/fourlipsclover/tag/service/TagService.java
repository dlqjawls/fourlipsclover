package com.patriot.fourlipsclover.tag.service;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.locals.document.LocalsDocument;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import com.patriot.fourlipsclover.locals.repository.LocalCertificationRepository;
import com.patriot.fourlipsclover.locals.repository.LocalsElasticsearchRepository;
import com.patriot.fourlipsclover.member.entity.MemberReviewTag;
import com.patriot.fourlipsclover.payment.entity.VisitPayment;
import com.patriot.fourlipsclover.payment.repository.VisitPaymentRepository;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.RestaurantImage;
import com.patriot.fourlipsclover.restaurant.entity.RestaurantTag;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.entity.SentimentStatus;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantImageRepository;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewSentimentRepository;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import com.patriot.fourlipsclover.tag.dto.response.RestaurantTagResponse;
import com.patriot.fourlipsclover.tag.dto.response.TagInfo;
import com.patriot.fourlipsclover.tag.dto.response.TagListResponse;
import com.patriot.fourlipsclover.tag.dto.response.TagResponse;
import com.patriot.fourlipsclover.tag.entity.Tag;
import com.patriot.fourlipsclover.tag.repository.MemberReviewTagRepository;
import com.patriot.fourlipsclover.tag.repository.RestaurantTagRepository;
import com.patriot.fourlipsclover.tag.repository.TagRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.elasticsearch.core.geo.GeoPoint;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

@Service
@RequiredArgsConstructor
public class TagService {

	// 리뷰 컨텐츠 가져와서 태그 뽑기, restaurantTag, MemberTag 추가해주기.
	private final TagRepository tagRepository;
	private final MemberReviewTagRepository memberReviewTagRepository;
	private final RestaurantTagRepository restaurantTagRepository;
	private final WebClient webClient;
	private final ElasticsearchClient elasticsearchClient;
	private final LocalsElasticsearchRepository localsElasticsearchRepository;
	private final LocalCertificationRepository localCertificationRepository;
	private final RestaurantJpaRepository restaurantJpaRepository;
	private final ReviewSentimentRepository reviewSentimentRepository;
	private final RestaurantImageRepository restaurantImageRepository;
	private final VisitPaymentRepository visitPaymentRepository;

	@Value("${model.server.uri}")
	private String MODEL_SERVER_URI;

	public void generateTag(Review review) {
		Map<String, String> requestMap = new HashMap<>();
		requestMap.put("text", review.getContent());
		String requestBody = null;
		try {
			requestBody = new ObjectMapper().writeValueAsString(requestMap);
		} catch (JsonProcessingException e) {
			throw new RuntimeException(e);
		}
		TagResponse tagResponse = webClient.post().uri(MODEL_SERVER_URI + "/extract-tags")
				.contentType(
						MediaType.APPLICATION_JSON).bodyValue(requestBody).retrieve()
				.bodyToMono(
						TagResponse.class).block();
		for (TagInfo tagInfo : tagResponse.getTags()) {
			Tag tag = tagRepository.findByName(tagInfo.getTag());

			memberReviewTagRepository.findByMemberAndTag(
							review.getMember().getMemberId(), tag.getName())
					.ifPresentOrElse(existingTag -> {
						existingTag.setFrequency(existingTag.getFrequency() + 1);
						existingTag.setAvgConfidence(
								(existingTag.getAvgConfidence() * (existingTag.getFrequency() - 1)
										+ tagInfo.getScore()) / existingTag.getFrequency());
						memberReviewTagRepository.save(existingTag);
					}, () -> {
						MemberReviewTag newTag = new MemberReviewTag();
						newTag.setMember(review.getMember());
						newTag.setTag(tag);
						newTag.setFrequency(1);
						newTag.setAvgConfidence(tagInfo.getScore());
						memberReviewTagRepository.save(newTag);
					});

			restaurantTagRepository.findByRestaurantKakaoPlaceIdAndTagName(
							review.getRestaurant().getKakaoPlaceId(), tag.getName())
					.ifPresentOrElse(existingTag -> {
						existingTag.setFrequency(existingTag.getFrequency() + 1);
						existingTag.setAvgConfidence(
								(existingTag.getAvgConfidence() * (existingTag.getFrequency() - 1)
										+ tagInfo.getScore()) / existingTag.getFrequency());
						restaurantTagRepository.save(existingTag);
					}, () -> {
						RestaurantTag newTag = new RestaurantTag();
						newTag.setFrequency(1);
						newTag.setAvgConfidence(tagInfo.getScore());
						newTag.setRestaurant(review.getRestaurant());
						newTag.setTag(tag);
						restaurantTagRepository.save(newTag);
					});


		}
		updateElasticsearchTags(review.getMember().getMemberId());

	}

	@Transactional(readOnly = true)
	public List<RestaurantTagResponse> findRestaurantTagByRestaurantId(String kakaoPlaceId) {
		List<RestaurantTag> restaurantTags = restaurantTagRepository.findRestaurantTagsByKakaoPlaceId(
				kakaoPlaceId);
		List<RestaurantTagResponse> response = new ArrayList<>();
		for (RestaurantTag data : restaurantTags) {
			RestaurantTagResponse responseDto = new RestaurantTagResponse();
			responseDto.setCategory(data.getTag().getCategory());
			responseDto.setTagName(data.getTag().getName());
			responseDto.setRestaurantTagId(data.getRestaurantTagId());
			response.add(responseDto);
		}
		return response;
	}

	@Transactional(readOnly = true)
	public List<RestaurantTagResponse> findRestaurantTagByMemberId(long memberId) {
		List<MemberReviewTag> memberTags = memberReviewTagRepository.findByMemberId(memberId);
		List<RestaurantTagResponse> tagList = new ArrayList<>();
		for (MemberReviewTag data : memberTags) {
			RestaurantTagResponse restaurantTagResponse = new RestaurantTagResponse();
			restaurantTagResponse.setRestaurantTagId(data.getMemberReviewTagId());
			restaurantTagResponse.setTagName(data.getTag().getName());
			restaurantTagResponse.setCategory(data.getTag().getCategory());
			tagList.add(restaurantTagResponse);
		}
		return tagList;
	}

	// 태그 전체 목록 조회
	public List<TagListResponse> getTagList() {
		List<Tag> tags = tagRepository.findAll();

		return tags.stream()
				.map(tag -> new TagListResponse(tag.getTagId(), tag.getCategory(), tag.getName()))
				.collect(Collectors.toList());
	}


	private void updateElasticsearchTags(Long memberId) {
		LocalCertification cert = localCertificationRepository.findByMember_MemberId(
				memberId).orElseThrow();
		// 멤버 태그 정보 조회
		List<MemberReviewTag> memberReviewTags = memberReviewTagRepository.findByMember(
				cert.getMember());
		List<LocalsDocument.TagData> tagDataList = memberReviewTags.stream()
				.map(tag -> LocalsDocument.TagData.builder()
						.tagName(tag.getTag().getName())
						.category(tag.getTag().getCategory())
						.frequency(tag.getFrequency())
						.avgConfidence(tag.getAvgConfidence())
						.build())
				.collect(Collectors.toList());
		// 지역명 정규화 (특별시, 광역시, 도 단위로)
		String regionName = cert.getLocalRegion().getRegion().getName();

		// LocalsDocument 생성
		LocalsDocument localsDocument = LocalsDocument.builder()
				.id(cert.getLocalCertificationId() + "")
				.memberId(cert.getMember().getMemberId())
				.nickname(cert.getMember().getNickname())
				.regionName(regionName)
				.localRegionId(cert.getLocalRegion().getLocalRegionId())
				.localGrade(cert.getLocalGrade().name())
				.tags(tagDataList)
				.profileUrl(cert.getMember().getProfileUrl())
				.build();

		// Elasticsearch에 저장
		localsElasticsearchRepository.save(localsDocument);
	}

	@Transactional(readOnly = true)
	public int uploadRestaurantDocument() {
		List<Restaurant> restaurants = restaurantJpaRepository.findAll();
		int count = 0;

		for (Restaurant restaurant : restaurants) {
			List<RestaurantTag> tags = restaurantTagRepository.findByRestaurant(restaurant);

			List<RestaurantDocument.TagData> tagDataList = tags.stream()
					.map(tag -> RestaurantDocument.TagData.builder()
							.tagName(tag.getTag().getName())
							.category(tag.getTag().getCategory())
							.frequency(tag.getFrequency())
							.avgConfidence(tag.getAvgConfidence())
							.build())
					.collect(Collectors.toList());

			int likeSentimentCount = reviewSentimentRepository.countByReview_RestaurantAndSentimentStatus(restaurant,
					SentimentStatus.POSITIVE);
			int dislikeSentimentCount = reviewSentimentRepository.countByReview_RestaurantAndSentimentStatus(restaurant,
					SentimentStatus.NEGATIVE);

			// 식당 이미지 조회 및 설정
			List<String> restaurantImages = restaurantImageRepository.findByRestaurant(restaurant).stream().map(
					RestaurantImage::getUrl).toList();


			// 가격 정보 실시간 계산
			String avgAmountJson = calculateAvgAmountJson(restaurant.getRestaurantId());
			RestaurantDocument restaurantDocument = RestaurantDocument.builder()
					.id(restaurant.getKakaoPlaceId())
					.restaurantId(restaurant.getRestaurantId())
					.openingHours(restaurant.getOpeningHours())
					.kakaoPlaceId(restaurant.getKakaoPlaceId())
					.name(restaurant.getPlaceName())
					.address(restaurant.getAddressName())
					.category(restaurant.getCategory())
					.likeSentiment(likeSentimentCount)
					.dislikeSentiment(dislikeSentimentCount)
					.location(new GeoPoint(restaurant.getY(), restaurant.getX()))
					.tags(tagDataList)
					.restaurantImages(restaurantImages)
					.avgAmount(avgAmountJson)
					.build();

			try {
				elasticsearchClient.index(i -> i
						.index("restaurants")
						.id(restaurant.getKakaoPlaceId())
						.document(restaurantDocument));
				count++;
			} catch (Exception e) {
				System.err.println(
						"레스토랑 인덱싱 실패: " + restaurant.getKakaoPlaceId() + " - " + e.getMessage());
			}
		}

		return count;
	}

	private String calculateAvgAmountJson(Integer restaurantId) {
		List<VisitPayment> payments = visitPaymentRepository.findByRestaurantId_RestaurantId(restaurantId);

		if (payments.isEmpty()) {
			return "{\"avg\": \"정보 없음\"}";
		}

		Map<String, Integer> avgAmountInfo = new LinkedHashMap<>();

		// 1인당 평균 금액 계산 (결제 건수 기준)
		for (VisitPayment payment : payments) {
			if (payment.getVisitedPersonnel() <= 0) continue;

			Integer perPersonAmount = payment.getAmount() / payment.getVisitedPersonnel();
			String range = calculatePriceRange(perPersonAmount);

			// 결제 건수를 기준으로 +1씩 증가
			avgAmountInfo.merge(range, 1, Integer::sum);
		}

		if (avgAmountInfo.isEmpty()) {
			return "{\"avg\": \"정보 없음\"}";
		}

		// 가장 많은 분포의 범위 찾기
		String avgPriceRange = avgAmountInfo.entrySet().stream()
				.max(Comparator.comparing(Map.Entry::getValue))
				.map(Map.Entry::getKey)
				.orElse("정보 없음");

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("avg", avgPriceRange);

		// 0이 아닌 값만 결과에 포함
		avgAmountInfo.forEach((key, value) -> {
			if (value > 0) {
				result.put(key, value);
			}
		});

		try {
			// JSON 문자열로 변환
			return new ObjectMapper().writeValueAsString(result);
		} catch (Exception e) {
			return "{\"avg\": \"정보 없음\"}";
		}
	}

	private String calculatePriceRange(Integer amount) {
		if (amount <= 10000) return "1 ~ 10000";
		if (amount <= 20000) return "10000 ~ 20000";
		if (amount <= 30000) return "20000 ~ 30000";
		if (amount <= 40000) return "30000 ~ 40000";
		if (amount <= 50000) return "40000 ~ 50000";
		if (amount <= 60000) return "50000 ~ 60000";
		if (amount <= 70000) return "60000 ~ 70000";
		if (amount <= 80000) return "70000 ~ 80000";
		if (amount <= 90000) return "80000 ~ 90000";
		if (amount <= 100000) return "90000 ~ 100000";
		return "100000 ~";
	}
}
