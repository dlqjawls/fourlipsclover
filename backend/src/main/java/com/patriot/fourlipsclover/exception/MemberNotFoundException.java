package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class MemberNotFoundException extends ApplicationException {

    public MemberNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

    public MemberNotFoundException(String message, Throwable cause, HttpStatus status) {
        super(message, cause, status);
    }

}
