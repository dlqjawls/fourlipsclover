package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ApiResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/restaurant")
@RequiredArgsConstructor
@Tag(name = "Restaurant", description = "식당 관련 API")
public class RestaurantController {

	private final RestaurantService restaurantService;

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

	@GetMapping("/{kakaoPlaceId}/search")
	public ResponseEntity<RestaurantResponse> findById(
			@PathVariable(name = "kakaoPlaceId") String kakaoPlaceId) {
		if (kakaoPlaceId == null || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("kakaoPlaceId는 비어있을 수 없습니다");
		}

		RestaurantResponse response = restaurantService.findRestaurantByKakaoPlaceId(kakaoPlaceId);
		return ResponseEntity.ok(response);
	}

	@PostMapping("/reviews")
	public ResponseEntity<ReviewResponse> create(@RequestBody ReviewCreate reviewCreate) {
		ReviewResponse response = restaurantService.create(reviewCreate);
		return ResponseEntity.ok(response);
	}

	@GetMapping("/{kakaoPlaceId}/reviews/{reviewId}")
	public ResponseEntity<ReviewResponse> reviewDetail(
			@PathVariable(name = "reviewId") Integer reviewId) {
		ReviewResponse response = restaurantService.findById(reviewId);
		return ResponseEntity.ok(response);
	}

	@GetMapping("/{kakaoPlaceId}/reviews")
	public ResponseEntity<List<ReviewResponse>> reviewList(
			@PathVariable(name = "kakaoPlaceId") String kakaoPlaceId) {
		if (kakaoPlaceId == null || kakaoPlaceId.isBlank()) {
			throw new IllegalArgumentException("kakaoPlaceId는 비어있을 수 없습니다");
		}
		List<ReviewResponse> response = restaurantService.findByKakaoPlaceId(kakaoPlaceId);
		return ResponseEntity.ok(response);
	}

	@PutMapping("/reviews/{reviewId}")
	public ResponseEntity<ReviewResponse> reviewUpdate(
			@PathVariable(name = "reviewId") Integer reviewId,
			@Valid @RequestBody ReviewUpdate reviewUpdate) {
		if (Objects.isNull(reviewId)) {
			throw new IllegalArgumentException("reviewId는 비어있을 수 없습니다");
		}

		ReviewResponse response = restaurantService.update(reviewId, reviewUpdate);
		return ResponseEntity.ok(response);
	}

	@DeleteMapping("/reviews/{reviewId}")
	public ResponseEntity<ReviewDeleteResponse> reviewDelete(
			@PathVariable(name = "reviewId") Integer reviewId) {
		ReviewDeleteResponse response = restaurantService.delete(reviewId);

		return ResponseEntity.ok(response);
	}

	@PostMapping(value = "/reviews/{reviewId}/like")
	public ResponseEntity<ApiResponse<String>> reviewLike(@PathVariable Integer reviewId,
			@RequestBody ReviewLikeCreate request) {
		String result = restaurantService.like(reviewId, request);
		ApiResponse<String> response = ApiResponse.<String>builder().data(result).message(result)
				.success(true).build();

		return ResponseEntity.ok(response);
	}
}
