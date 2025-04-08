package com.patriot.fourlipsclover.settlement.dto.response;

import com.patriot.fourlipsclover.settlement.entity.Settlement.SettlementStatus;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SettlementSituationResponse {

	private Integer settlementId;

	private String planName;

	private Integer planId;

	private String treasurerName;

	private Long treasurerId;

	private SettlementStatus settlementStatus;

	private LocalDateTime startDate;

	private LocalDateTime endDate;

	private List<SettlementTransactionResponse> settlementTransactionResponses;
}
