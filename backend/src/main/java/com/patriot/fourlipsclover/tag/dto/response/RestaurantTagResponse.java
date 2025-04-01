package com.patriot.fourlipsclover.tag.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantTagResponse {

	private Long restaurantTagId;

	private String tagName;

	private String category;
}
