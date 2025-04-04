package com.patriot.fourlipsclover.settlement.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class ExpenseParticipantResponse {

	private Long expenseParticipantId;

	private Long memberId;

	private String email;

	private String nickname;

	private String profileUrl;
}
