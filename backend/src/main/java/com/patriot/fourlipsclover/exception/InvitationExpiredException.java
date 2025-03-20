package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class InvitationExpiredException extends ApplicationException {
    public InvitationExpiredException(String message) {
        super(message, HttpStatus.BAD_REQUEST);
    }

    public InvitationExpiredException(String message, Throwable cause) {
        super(message, cause, HttpStatus.BAD_REQUEST);
    }
}
