package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class MatchNotFoundException extends ApplicationException {
    public MatchNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

}
