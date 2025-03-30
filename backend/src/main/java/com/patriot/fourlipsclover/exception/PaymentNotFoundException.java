package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class PaymentNotFoundException extends ApplicationException {
    public PaymentNotFoundException(String message) {
        super(message, HttpStatus.NOT_FOUND);
    }

}
