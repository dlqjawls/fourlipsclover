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

@Document(indexName = "restaurant")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantDocument {

	@Id
	private String id;

	@Field(type = FieldType.Text)
	private String openingHours;

	@Field(type = FieldType.Nested)
	private List<String> restaurantImages;

	@Field(type = FieldType.Text)
	private String avgAmount;
	@Field(type = FieldType.Keyword)
	private String phone;
	@Field(type = FieldType.Text)
	private String name;
	@Field(type = FieldType.Text, analyzer = "nori")
	private String address;
	@Field(type = FieldType.Text, analyzer = "nori")
	private String category;
	@Field(type = FieldType.Nested)
	private List<TagData> tags;
	@GeoPointField
	private GeoPoint location;

	@Field(type = FieldType.Double)
	private Double score;

	@Field(type = FieldType.Keyword)
	private String kakaoPlaceId;

	@Field(type = FieldType.Integer)
	private Integer restaurantId;

	@Field(type = FieldType.Integer)
	private Integer likeSentiment;
	@Field(type = FieldType.Integer)
	private Integer dislikeSentiment;
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
