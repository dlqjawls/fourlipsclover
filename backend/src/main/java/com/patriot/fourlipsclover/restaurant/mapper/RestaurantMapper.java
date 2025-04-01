package com.patriot.fourlipsclover.restaurant.mapper;

import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import java.util.List;
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

	public List<RestaurantResponse> documentToDto(List<RestaurantDocument> restaurantDocuments) {
		return restaurantDocuments.stream()
				.map(doc -> RestaurantResponse.builder()
						.restaurantId(doc.getRestaurantId())
						.kakaoPlaceId(doc.getKakaoPlaceId())
						.placeName(doc.getName())
						.addressName(doc.getAddress())
						.category(doc.getCategory())
						// 다른 필드들은 Elasticsearch document에 존재하지 않으므로 null로 설정됩니다
						// 필요하다면 추가 데이터를 가져오는 로직이 필요할 수 있습니다
						.x(doc.getLocation() != null ? doc.getLocation().getLat() : null)
						.y(doc.getLocation() != null ? doc.getLocation().getLon() : null)
						.build())
				.toList();
	}
}
