package com.patriot.fourlipsclover.settlement.dto.response;

import com.patriot.fourlipsclover.settlement.entity.Settlement.SettlementStatus;
import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;

@Data
public class SettlementResponse {

	private Integer settlementId;
	
	private String planName;
	private Integer planId;
	private String treasurerName;
	private Long treasurerId;

	private SettlementStatus settlementStatus;

	private LocalDateTime startDate;


	private LocalDateTime endDate;

	private LocalDateTime createdAt;

	private LocalDateTime updatedAt;

	private List<ExpenseResponse> expenseResponses;
}
