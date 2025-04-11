package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class InvitationMismatchException extends ApplicationException {
    public InvitationMismatchException(String message) {
        super(message, HttpStatus.FORBIDDEN);
    }

    public InvitationMismatchException(String message, Throwable cause) {
        super(message, cause, HttpStatus.FORBIDDEN);
    }
}
