package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class PlanNotFoundException extends ApplicationException {
    public PlanNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }
    
}
