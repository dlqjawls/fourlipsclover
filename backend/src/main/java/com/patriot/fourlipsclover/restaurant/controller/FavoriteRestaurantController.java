package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.response.FavoriteRestaurantResponse;
import com.patriot.fourlipsclover.restaurant.service.FavoriteRestaurantService;
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
	public ResponseEntity<Void> create(@PathVariable Integer restaurantId, @RequestParam Long memberId){
		favoriteRestaurantService.create(restaurantId, memberId);
		return ResponseEntity.ok().build();
	}

	@GetMapping("/{memberId}/favorite")
	public ResponseEntity<List<FavoriteRestaurantResponse>> findByMemberId(@PathVariable Long memberId){
		List<FavoriteRestaurantResponse> response = favoriteRestaurantService.findByMemberId(memberId);
		return ResponseEntity.ok(response);
	}

	@DeleteMapping("/{restaurantId}/favorite/{memberId}")
	public ResponseEntity<Void> delete(@PathVariable Integer restaurantId, @PathVariable Long memberId){
		favoriteRestaurantService.delete(restaurantId, memberId);
		return ResponseEntity.noContent().build();
	}
}
