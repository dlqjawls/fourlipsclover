package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReviewDeleteResponse {

	private String message;
	private Integer reviewId;
}
