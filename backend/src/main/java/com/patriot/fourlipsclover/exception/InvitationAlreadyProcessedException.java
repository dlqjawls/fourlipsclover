package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class InvitationAlreadyProcessedException extends ApplicationException {
    public InvitationAlreadyProcessedException(String message) {
        super(message, HttpStatus.BAD_REQUEST);
    }

    public InvitationAlreadyProcessedException(String message, Throwable cause) {
        super(message, cause, HttpStatus.BAD_REQUEST);
    }
}