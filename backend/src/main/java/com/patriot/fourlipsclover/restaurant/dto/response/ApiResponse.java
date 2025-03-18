package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.Builder;

@Builder
public class ApiResponse<T> {

	private boolean success;
	private T data;
	private String message;
}