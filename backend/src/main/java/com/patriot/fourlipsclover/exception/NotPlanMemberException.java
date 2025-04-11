package com.patriot.fourlipsclover.exception;

import org.springframework.http.HttpStatus;

public class NotPlanMemberException extends ApplicationException {

    public NotPlanMemberException(String message) {
        super(message, HttpStatus.FORBIDDEN);
    }

}
