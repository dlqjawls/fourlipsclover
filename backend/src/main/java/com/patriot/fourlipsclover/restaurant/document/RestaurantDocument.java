package com.patriot.fourlipsclover.restaurant.document;

import com.patriot.fourlipsclover.locals.document.LocalsDocument.TagData;
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
	private List<TagData> tags;
	@GeoPointField
	private GeoPoint location;

	@Field(type = FieldType.Keyword)
	private String kakaoPlaceId;

	@Field(type = FieldType.Keyword)
	private Integer restaurantId;

	@Data
	@NoArgsConstructor
	@AllArgsConstructor
	@Builder
	public static class TagData {

		@Field(type = FieldType.Text, analyzer = "nori")
		private String tagName;

		@Field(type = FieldType.Keyword)
		private String category;

		@Field(type = FieldType.Integer)
		private int frequency;

		@Field(type = FieldType.Float)
		private float avgConfidence;
	}
}
