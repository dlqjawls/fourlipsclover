package com.patriot.fourlipsclover.restaurant.dto.request;

import lombok.Getter;

@Getter
public enum LikeStatus {
	LIKE("LIKE"),
	DISLIKE("DISLIKE");

	private final String status;

	LikeStatus(String status) {
		this.status = status;
	}

}