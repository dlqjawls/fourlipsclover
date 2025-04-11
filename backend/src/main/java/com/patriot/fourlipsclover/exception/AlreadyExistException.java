package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class AlreadyExistException extends ApplicationException {

    public AlreadyExistException(String message) {
        super(message, HttpStatus.ALREADY_REPORTED);
    }

}
