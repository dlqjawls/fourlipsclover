package com.patriot.fourlipsclover.restaurant.mapper;

import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface RestaurantSearchMapper {

	@Mapping(source = "name", target = "placeName")
	@Mapping(source = "address", target = "addressName")
	@Mapping(source = "location.lon", target = "x")
	@Mapping(source = "location.lat", target = "y")
	RestaurantResponse toResponse(RestaurantDocument restaurantDocument);

	@Mapping(source = "tagName", target = "tagName")
	@Mapping(source = "category", target = "category")
	@Mapping(source = "frequency", target = "frequency")
	@Mapping(source = "avgConfidence", target = "avgConfidence")
	RestaurantResponse.TagData toTagData(RestaurantDocument.TagData tagData);
}
