package com.patriot.fourlipsclover.settlement.exception;

public class AlreadyExistsExpenseParticipantException extends IllegalArgumentException {

	public AlreadyExistsExpenseParticipantException(Long expenseId, Long planMemberId) {
		super(String.format("이미 존재하는 정산 참가자입니다. 비용 ID: %d, 계획 멤버 ID: %d", expenseId, planMemberId));
	}
}
