package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class RestaurantNotFoundException extends ApplicationException {
    public RestaurantNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

    public RestaurantNotFoundException(String message, Throwable cause, HttpStatus status) {
        super(message, cause, status);
    }
}
