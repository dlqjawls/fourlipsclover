package com.patriot.fourlipsclover.restaurant.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewLikeCreate {

	private Integer memberId;
	private Integer reviewId;
	private LikeStatus likeStatus;

	public enum LikeStatus {
		LIKE("LIKE"),
		DISLIKE("DISLIKE");

		private final String status;

		LikeStatus(String status) {
			this.status = status;
		}

		public String getStatus() {
			return status;
		}
	}
}
