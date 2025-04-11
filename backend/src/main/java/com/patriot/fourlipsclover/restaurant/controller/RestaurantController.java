package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.locals.service.LocalsElasticsearchService;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ApiResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.service.RestaurantElasticsearchService;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/restaurant")
@RequiredArgsConstructor
@Tag(name = "Restaurant", description = "식당 관련 API")
public class RestaurantController {

	private final RestaurantService restaurantService;
	private final RestaurantElasticsearchService restaurantElasticsearchService;
	private final LocalsElasticsearchService localsElasticsearchService;

	@Operation(summary = "그룹 맞춤 식당 추천", description = "그룹 ID를 기반으로 그룹 멤버들의 선호도에 맞는 식당을 추천합니다")
	@GetMapping("/{planId}/recommend")
	public ResponseEntity<List<RestaurantResponse>> recommendRestaurantsForGroup(
			@Parameter(description = "그룹 ID") @PathVariable Integer planId) {
		return ResponseEntity.ok(
				localsElasticsearchService.recommendSimilarRestaurants(planId));
	}

	@GetMapping("/nearby")
	@Operation(
			summary = "인근 식당 검색",
			description = "위도/경도 기반으로 주변 식당을 검색합니다."
	)
	public ResponseEntity<List<RestaurantResponse>> locationSearch(
			@Parameter(description = "위도 값", required = true) @RequestParam Double latitude,
			@Parameter(description = "경도 값", required = true) @RequestParam Double longitude,
			@Parameter(description = "검색 반경(미터)", required = true) @RequestParam Integer radius) {
		List<RestaurantResponse> response = restaurantElasticsearchService.searchRestaurantsByLocation(
				latitude, longitude, radius);
		return ResponseEntity.ok(response);
	}

	@GetMapping("/search")
	@Operation(
			summary = "태그 및 검색어 기반 식당 검색",
			description = "태그 ID 목록과 검색어를 조합하여 식당을 검색합니다."
	)
	public ResponseEntity<List<RestaurantResponse>> searchByTagsAndQuery(
			@RequestParam(required = false) String query,
			@RequestParam(required = false) List<Long> tagIds) {
		if ((query == null || query.isBlank()) && (tagIds == null || tagIds.isEmpty())) {
			throw new IllegalArgumentException("검색어 또는 태그 중 최소 하나는 제공해야 합니다.");
		}
		List<RestaurantResponse> response = restaurantElasticsearchService.searchByTagsAndQuery(
				query, tagIds);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "식당 상세 조회", description = "카카오 Place ID를 이용하여 식당 정보를 조회합니다.")
	@GetMapping("/{kakaoPlaceId}/search")
	public ResponseEntity<RestaurantResponse> findById(
			@Parameter(description = "카카오 Place ID", required = true) @PathVariable(name = "kakaoPlaceId") String kakaoPlaceId) {
		if (kakaoPlaceId == null || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("kakaoPlaceId는 비어있을 수 없습니다");
		}
		RestaurantResponse response = restaurantElasticsearchService.findRestaurantByKakaoPlaceId(
				kakaoPlaceId);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "리뷰 생성", description = "식당에 대한 리뷰를 생성합니다. 이미지를 선택적으로 첨부할 수 있습니다.")
	@PostMapping(value = "/reviews", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<ReviewResponse> create(
			@Parameter(description = "리뷰 생성 정보", required = true) @RequestPart("data") ReviewCreate reviewCreate,
			@Parameter(description = "리뷰 이미지 파일 (선택사항)") @RequestPart(value = "images", required = false) List<MultipartFile> images) {
		ReviewResponse response = restaurantService.create(reviewCreate, images);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "리뷰 상세 조회", description = "특정 식당의 특정 리뷰 정보를 조회합니다.")
	@GetMapping("/{kakaoPlaceId}/reviews/{reviewId}")
	public ResponseEntity<ReviewResponse> reviewDetail(
			@Parameter(description = "카카오 Place ID", required = true) @PathVariable(name = "kakaoPlaceId") String kakaoPlaceId,
			@Parameter(description = "리뷰 ID", required = true) @PathVariable(name = "reviewId") Integer reviewId) {
		ReviewResponse response = restaurantService.findById(reviewId);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "식당 리뷰 목록 조회", description = "특정 식당의 모든 리뷰를 조회합니다.")
	@GetMapping("/{kakaoPlaceId}/reviews")
	public ResponseEntity<List<ReviewResponse>> reviewList(
			@Parameter(description = "카카오 Place ID", required = true) @PathVariable(name = "kakaoPlaceId") String kakaoPlaceId) {
		if (kakaoPlaceId == null || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("kakaoPlaceId는 비어있을 수 없습니다");
		}
		List<ReviewResponse> response = restaurantService.findByKakaoPlaceId(kakaoPlaceId);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "리뷰 수정", description = "식당에 대한 리뷰를 수정합니다.")
	@PutMapping(value = "/reviews/{reviewId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<ReviewResponse> reviewUpdate(
			@PathVariable(name = "reviewId") Integer reviewId,
			@Valid @RequestPart(name = "data") ReviewUpdate reviewUpdate,
			@RequestPart(name = "deleteImageUrls", required = false) List<String> deleteImageUrls,
			@RequestPart(name = "images", required = false) List<MultipartFile> images) {
		if (Objects.isNull(reviewId)) {
			throw new IllegalArgumentException("reviewId는 비어있을 수 없습니다");
		}

		ReviewResponse response = restaurantService.update(reviewId, reviewUpdate, deleteImageUrls,
				images);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "리뷰 삭제", description = "특정 리뷰를 삭제합니다.")
	@DeleteMapping("/reviews/{reviewId}")
	public ResponseEntity<ReviewDeleteResponse> reviewDelete(
			@Parameter(description = "리뷰 ID", required = true) @PathVariable(name = "reviewId") Integer reviewId) {
		ReviewDeleteResponse response = restaurantService.delete(reviewId);

		return ResponseEntity.ok(response);
	}

	@Operation(summary = "리뷰 좋아요", description = "특정 리뷰에 좋아요를 추가합니다.")
	@PostMapping(value = "/reviews/{reviewId}/like")
	public ResponseEntity<ApiResponse<String>> reviewLike(
			@Parameter(description = "리뷰 ID", required = true) @PathVariable Integer reviewId,
			@Parameter(description = "좋아요 정보", required = true) @RequestBody ReviewLikeCreate request) {
		String result = restaurantService.like(reviewId, request);
		ApiResponse<String> response = ApiResponse.<String>builder().data(result).message(result)
				.success(true).build();

		return ResponseEntity.ok(response);
	}
}
