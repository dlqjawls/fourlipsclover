package com.patriot.fourlipsclover.exception;

public class ReviewNotFoundException extends RuntimeException {

	public ReviewNotFoundException(Integer id) {
		super("리뷰를 찾을 수 없습니다. ID: " + id);
	}
}
