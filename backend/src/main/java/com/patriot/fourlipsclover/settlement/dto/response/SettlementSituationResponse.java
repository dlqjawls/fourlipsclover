package com.patriot.fourlipsclover.settlement.dto.response;

import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction.TransactionStatus;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SettlementSituationResponse {

	private Long settlementTransactionId;


	private SettlementMemberResponse payee;

	private SettlementMemberResponse payer;

	private TransactionStatus transactionStatus;

	private LocalDateTime createdAt;

	private LocalDateTime sentAt;
}
