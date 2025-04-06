package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.response.FavoriteRestaurantResponse;
import com.patriot.fourlipsclover.restaurant.service.FavoriteRestaurantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/restaurant")
public class FavoriteRestaurantController {
	private final FavoriteRestaurantService favoriteRestaurantService;

	@PostMapping("/{restaurantId}/favorite")
	@Operation(
			summary = "레스토랑 즐겨찾기 등록",
			description = "사용자가 레스토랑을 즐겨찾기에 추가합니다."
	)
	@ApiResponses(value = {
			@ApiResponse(
					responseCode = "200",
					description = "즐겨찾기 등록 성공"
			),
			@ApiResponse(
					responseCode = "404",
					description = "레스토랑이나 사용자를 찾을 수 없음"
			)
	})
	public ResponseEntity<Void> create(
			@Parameter(description = "레스토랑 ID", required = true)
			@PathVariable Integer restaurantId,
			@Parameter(description = "회원 ID", required = true)
			@RequestParam Long memberId) {
		favoriteRestaurantService.create(restaurantId, memberId);
		return ResponseEntity.ok().build();
	}

	@GetMapping("/{memberId}/favorite")
	@Operation(
			summary = "회원 즐겨찾기 레스토랑 조회",
			description = "특정 회원이 즐겨찾기에 등록한 레스토랑 목록을 조회합니다."
	)
	@ApiResponses(value = {
			@ApiResponse(
					responseCode = "200",
					description = "즐겨찾기 조회 성공"
			),
			@ApiResponse(
					responseCode = "404",
					description = "회원을 찾을 수 없음"
			)
	})
	public ResponseEntity<List<FavoriteRestaurantResponse>> findByMemberId(
			@Parameter(description = "회원 ID", required = true)
			@PathVariable Long memberId) {
		List<FavoriteRestaurantResponse> response = favoriteRestaurantService.findByMemberId(memberId);
		return ResponseEntity.ok(response);
	}

	@DeleteMapping("/{restaurantId}/favorite/{memberId}")
	@Operation(
			summary = "레스토랑 즐겨찾기 삭제",
			description = "사용자가 즐겨찾기에 등록한 레스토랑을 삭제합니다."
	)
	@ApiResponses(value = {
			@ApiResponse(
					responseCode = "204",
					description = "즐겨찾기 삭제 성공"
			),
			@ApiResponse(
					responseCode = "404",
					description = "레스토랑이나 사용자를 찾을 수 없음"
			)
	})
	public ResponseEntity<Void> delete(
			@Parameter(description = "레스토랑 ID", required = true)
			@PathVariable Integer restaurantId,
			@Parameter(description = "회원 ID", required = true)
			@PathVariable Long memberId) {
		favoriteRestaurantService.delete(restaurantId, memberId);
		return ResponseEntity.noContent().build();
	}
}
