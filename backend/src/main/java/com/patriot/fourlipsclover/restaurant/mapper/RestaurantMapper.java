package com.patriot.fourlipsclover.restaurant.mapper;

import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import org.springframework.stereotype.Component;

@Component
public class RestaurantMapper {

	public RestaurantResponse toDto(Restaurant restaurant) {
		return RestaurantResponse.builder()
				.restaurantId(restaurant.getRestaurantId())
				.kakaoPlaceId(restaurant.getKakaoPlaceId())
				.placeName(restaurant.getPlaceName())
				.addressName(restaurant.getAddressName())
				.roadAddressName(restaurant.getRoadAddressName())
				.category(restaurant.getCategory())
				.categoryName(restaurant.getCategoryName())
				.phone(restaurant.getPhone())
				.placeUrl(restaurant.getPlaceUrl())
				.x(restaurant.getX())
				.y(restaurant.getY())
				.build();
	}
}
