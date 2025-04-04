package com.patriot.fourlipsclover.settlement.mapper;

import com.patriot.fourlipsclover.settlement.dto.response.ExpenseParticipantResponse;
import com.patriot.fourlipsclover.settlement.dto.response.ExpenseResponse;
import com.patriot.fourlipsclover.settlement.entity.Expense;
import com.patriot.fourlipsclover.settlement.entity.ExpenseParticipant;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ExpenseMapper {

	@Mapping(source = "expense.expenseId", target = "expenseId")
	@Mapping(source = "expense.paymentApproval.id", target = "paymentApprovalId")
	@Mapping(source = "expense.paymentApproval.amount.total", target = "totalPayment")
	@Mapping(source = "expense.paymentApproval.approvedAt", target = "approvedAt")
	@Mapping(source = "participants", target = "expenseParticipants")
	ExpenseResponse toDto(Expense expense, List<ExpenseParticipant> participants);


	@Mapping(source = "expenseParticipantId", target = "expenseParticipantId")
	@Mapping(source = "member.memberId", target = "memberId")
	@Mapping(source = "member.email", target = "email")
	@Mapping(source = "member.nickname", target = "nickname")
	@Mapping(source = "member.profileUrl", target = "profileUrl")
	ExpenseParticipantResponse toExpenseParticipantResponse(ExpenseParticipant expenseParticipant);

	default List<ExpenseParticipantResponse> toExpenseParticipantResponseList(
			List<ExpenseParticipant> expenseParticipants) {
		return expenseParticipants.stream()
				.map(this::toExpenseParticipantResponse)
				.toList();
	}
}
