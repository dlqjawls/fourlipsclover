package com.patriot.fourlipsclover.restaurant.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewLikeCreate {

	private Integer memberId;
	private LikeStatus likeStatus;
}
