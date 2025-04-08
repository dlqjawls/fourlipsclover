package com.patriot.fourlipsclover.restaurant.dto.response;

import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument.TagData;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.annotations.GeoPointField;
import org.springframework.data.elasticsearch.core.geo.GeoPoint;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantSearchResponse {

	private String id;
	private String openingHours;
	private List<String> restaurantImages;
	private String avgAmount;
	private String placeName;
	private String addressName;
	private String category;
	private List<TagData> tags;
	private Double x;
	private Double y;
	private String kakaoPlaceId;
	private Integer restaurantId;
	private Integer likeSentiment;
	private Integer dislikeSentiment;

	@Data
	@NoArgsConstructor
	@AllArgsConstructor
	@Builder
	public static class TagData {
		private String tagName;
		private String category;
		private int frequency;
		private float avgConfidence;
	}
}
