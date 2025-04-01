package com.patriot.fourlipsclover.restaurant.controller;

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

	/**
	 * 레스토랑 검색 API 엔드포인트
	 *
	 * @param query 검색어 (예: "장덕동 고깃집")
	 * @return 검색된 레스토랑 목록
	 */
	@Operation(summary = "식당 검색", description = "검색어를 이용하여 식당을 검색합니다.")
	@GetMapping("/search")
	public ResponseEntity<List<RestaurantResponse>> searchRestaurants(
			@Parameter(description = "검색어 (예: \"장덕동 고깃집\")", required = true) @RequestParam String query) {
		List<RestaurantResponse> results = restaurantElasticsearchService.searchRestaurants(
				query);
		return ResponseEntity.ok(results);
	}

	@Operation(summary = "주변 식당 검색", description = "위도/경도 기반으로 주변 식당을 검색합니다.")
	@GetMapping("/nearby")
	public ResponseEntity<List<RestaurantResponse>> findNearbyRestaurants(
			@Parameter(description = "위도 값") @RequestParam(required = true) Double latitude,
			@Parameter(description = "경도 값") @RequestParam(required = true) Double longitude,
			@Parameter(description = "검색 반경(미터)") @RequestParam(defaultValue = "1000") Integer radius) {

		if (latitude == null || longitude == null) {
			throw new IllegalArgumentException("위도와 경도는 필수 입력값입니다");
		}

		List<RestaurantResponse> nearbyRestaurants =
				restaurantService.findNearbyRestaurants(latitude, longitude, radius);

		return ResponseEntity.ok(nearbyRestaurants);
	}

	@Operation(summary = "식당 상세 조회", description = "카카오 Place ID를 이용하여 식당 정보를 조회합니다.")
	@GetMapping("/{kakaoPlaceId}/search")
	public ResponseEntity<RestaurantResponse> findById(
			@Parameter(description = "카카오 Place ID", required = true) @PathVariable(name = "kakaoPlaceId") String kakaoPlaceId) {
		if (kakaoPlaceId == null || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("kakaoPlaceId는 비어있을 수 없습니다");
		}

		RestaurantResponse response = restaurantService.findRestaurantByKakaoPlaceId(kakaoPlaceId);
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
	@PutMapping("/reviews/{reviewId}")
	public ResponseEntity<ReviewResponse> reviewUpdate(
			@Parameter(description = "리뷰 ID", required = true) @PathVariable(name = "reviewId") Integer reviewId,
			@Parameter(description = "수정할 리뷰 정보", required = true) @Valid @RequestBody ReviewUpdate reviewUpdate) {
		if (Objects.isNull(reviewId)) {
			throw new IllegalArgumentException("reviewId는 비어있을 수 없습니다");
		}

		ReviewResponse response = restaurantService.update(reviewId, reviewUpdate);
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
