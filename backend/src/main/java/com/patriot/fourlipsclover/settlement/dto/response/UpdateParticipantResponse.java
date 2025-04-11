package com.patriot.fourlipsclover.settlement.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class UpdateParticipantResponse {

	private Long expenseId;
	private List<ExpenseParticipantResponse> participants;
}
