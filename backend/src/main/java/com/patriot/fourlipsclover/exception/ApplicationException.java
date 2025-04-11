package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public abstract class ApplicationException extends RuntimeException {
    private final HttpStatus status;

    public ApplicationException(String message, HttpStatus status) {
        super(message);
        this.status = status;
    }

    public ApplicationException(String message, Throwable cause, HttpStatus status) {
        super(message, cause);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
