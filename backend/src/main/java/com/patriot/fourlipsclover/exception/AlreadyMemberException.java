package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class AlreadyMemberException extends ApplicationException {

    public AlreadyMemberException(String message) {
        super(message, HttpStatus.ALREADY_REPORTED);
    }

    public AlreadyMemberException(String message, Throwable cause, HttpStatus status) {
        super(message, cause, status);
    }
}
