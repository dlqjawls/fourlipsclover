package com.patriot.fourlipsclover.settlement.dto.response;

import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction.TransactionStatus;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SettlementTransactionResponse {

	private Long settlementTransactionId;

	private Integer cost;

	private SettlementMemberResponse payee;                    // 수취인

	private SettlementMemberResponse payer;                    // 송금자
	
	private TransactionStatus transactionStatus; // ENUM 혹은 상태 코드

	private LocalDateTime createdAt;

	private LocalDateTime sentAt;
}
