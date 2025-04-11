package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class ReviewRestaurantResponse {

	private Integer restaurantId;

	private String kakaoPlaceId;

	private String placeName;

	private String addressName;

	private String roadAddressName;

	private String category;

	private String categoryName;
}
