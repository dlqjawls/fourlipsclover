package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantResponse {

	private Integer restaurantId;
	private String kakaoPlaceId;
	private String placeName;
	private String addressName;
	private String roadAddressName;
	private String category;
	private String categoryName;
	private String phone;
	private String placeUrl;
	private Double x;
	private Double y;
}
