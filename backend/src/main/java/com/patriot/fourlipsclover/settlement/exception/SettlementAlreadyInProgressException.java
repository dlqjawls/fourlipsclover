package com.patriot.fourlipsclover.settlement.exception;

public class SettlementAlreadyInProgressException extends IllegalArgumentException {

	public SettlementAlreadyInProgressException(Integer settlementId) {
		super("정산 ID " + settlementId + "번은 이미 진행 중입니다. 해당 정산이 완료된 후 다시 시도해주세요.");
	}
}
