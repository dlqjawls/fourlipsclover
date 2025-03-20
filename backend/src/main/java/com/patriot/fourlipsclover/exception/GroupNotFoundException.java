package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class GroupNotFoundException extends ApplicationException {
    public GroupNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

    public GroupNotFoundException(String message, Throwable cause) {
        super(message, cause, HttpStatus.NOT_FOUND);
    }
}
