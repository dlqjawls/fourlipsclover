package com.patriot.fourlipsclover.settlement.exception;

public class ExpenseNotFoundException extends IllegalArgumentException {

	public ExpenseNotFoundException(Long expenseId) {
		super(String.format("존재하지 않는 정산 ID 입니다: %d", expenseId));
	}
}
