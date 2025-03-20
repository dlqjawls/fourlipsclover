package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class NotGroupMemberException extends ApplicationException {
    public NotGroupMemberException(String message) {
        super(message, HttpStatus.FORBIDDEN);
    }

    public NotGroupMemberException(String message, Throwable cause) {
        super(message, cause, HttpStatus.FORBIDDEN);
    }
}
