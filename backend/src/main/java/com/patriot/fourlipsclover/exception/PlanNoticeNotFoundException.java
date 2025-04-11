package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class PlanNoticeNotFoundException extends ApplicationException {
    public PlanNoticeNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

    public PlanNoticeNotFoundException(String message, Throwable cause) {
        super(message, cause, HttpStatus.NOT_FOUND);
    }
}
