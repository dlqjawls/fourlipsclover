package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ApiResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/restaurant")
@RequiredArgsConstructor
public class RestaurantController {

	private final RestaurantService restaurantService;

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
