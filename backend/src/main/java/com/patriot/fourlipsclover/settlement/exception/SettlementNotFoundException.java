package com.patriot.fourlipsclover.settlement.exception;

public class SettlementNotFoundException extends IllegalArgumentException {

	public SettlementNotFoundException(Integer planId) {
		super("계획 ID: " + planId + "에 해당하는 정산 정보를 찾을 수 없습니다.");
	}

}
