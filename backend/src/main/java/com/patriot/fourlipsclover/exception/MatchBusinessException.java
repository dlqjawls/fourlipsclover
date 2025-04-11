package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class MatchBusinessException extends ApplicationException {

    public MatchBusinessException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

    public MatchBusinessException(String message, Throwable cause, HttpStatus status) {
        super(message, cause, status);
    }

}
