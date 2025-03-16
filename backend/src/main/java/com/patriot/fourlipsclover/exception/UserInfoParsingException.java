package com.patriot.fourlipsclover.exception;

public class UserInfoParsingException extends RuntimeException {

    public UserInfoParsingException(String message) {
        super(message);
    }

    public UserInfoParsingException(String message, Throwable cause) {
        super(message, cause);
    }
}
