package com.patriot.fourlipsclover.restaurant.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantResponse {

	private String openingHours;
	private List<String> restaurantImages;
	private String avgAmount;
	private String placeName;
	private String addressName;
	private String category;
	private String phone;
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
