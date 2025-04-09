package com.patriot.fourlipsclover.settlement.exception;

public class TransactionNotFoundException extends RuntimeException {
	public TransactionNotFoundException() {
		super("거래 내역을 찾을 수 없습니다.");
	}
}
