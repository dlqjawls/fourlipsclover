package com.patriot.fourlipsclover.restaurant.mapper;

import com.patriot.fourlipsclover.restaurant.dto.response.FavoriteRestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.favorite.FavoriteRestaurant;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface FavoriteRestaurantMapper {

	List<FavoriteRestaurantResponse> toDtoList(List<FavoriteRestaurant> favoriteRestaurants);

	@Mapping(source = "favoriteRestaurantId", target = "favoriteRestaurantId")
	@Mapping(source = "member.memberId", target = "memberId")
	@Mapping(source = "member.nickname", target = "nickname")
	@Mapping(source = "member.profileUrl", target = "profileUrl")
	FavoriteRestaurantResponse toDto(FavoriteRestaurant favoriteRestaurant);

}
