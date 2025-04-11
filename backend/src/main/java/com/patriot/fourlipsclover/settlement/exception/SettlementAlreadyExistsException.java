package com.patriot.fourlipsclover.settlement.exception;

public class SettlementAlreadyExistsException extends IllegalArgumentException {

	public SettlementAlreadyExistsException(Integer planId) {
		super("이미 해당 계획에 대한 정산이 존재합니다. (계획 ID: " + planId + ")");
	}
}
