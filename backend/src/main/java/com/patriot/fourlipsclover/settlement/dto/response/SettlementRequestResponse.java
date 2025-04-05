package com.patriot.fourlipsclover.settlement.dto.response;

import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class SettlementRequestResponse {

	private Integer settlementId;
	private String planTitle;
	private TreasurerResponse treasurer;
	private List<SettlementTransactionResponse> settlementTransactionResponses;
	private LocalDateTime requestedDate;
}
