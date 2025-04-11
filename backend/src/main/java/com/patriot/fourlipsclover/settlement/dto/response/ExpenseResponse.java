package com.patriot.fourlipsclover.settlement.dto.response;

import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ExpenseResponse {

	private Long expenseId;
	private Long paymentApprovalId;
	private String itemName;
	private Integer totalPayment;
	private LocalDateTime approvedAt;
	private List<ExpenseParticipantResponse> expenseParticipants;
}
