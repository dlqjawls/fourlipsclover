package com.patriot.fourlipsclover.restaurant.document;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.annotations.GeoPointField;
import org.springframework.data.elasticsearch.core.geo.GeoPoint;

@Document(indexName = "restaurants")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantDocument {

	@Id
	private String id;
	@Field(type = FieldType.Text, analyzer = "korean")
	private String name;
	@Field(type = FieldType.Text, analyzer = "korean")
	private String address;
	@Field(type = FieldType.Text, analyzer = "korean")
	private String category;
	@Field(type = FieldType.Nested)
	private List<String> tags;
	@GeoPointField
	private GeoPoint location;

	@Field(type = FieldType.Keyword)
	private String kakaoPlaceId;

	@Field(type = FieldType.Keyword)
	private Integer restaurantId;
}
