package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/restaurant")
@RequiredArgsConstructor
public class RestaurantController {
	private final RestaurantService restaurantService;

	@PostMapping("/reviews")
	public ResponseEntity<ReviewResponse> create(@RequestBody ReviewCreate reviewCreate){
		ReviewResponse response = restaurantService.create(reviewCreate);
		return ResponseEntity.ok(response);
	}

}
