package com.patriot.fourlipsclover.restaurant.dto.response;

public class ApiResponse<T> {

	private boolean success;
	private T data;
	private String message;
}