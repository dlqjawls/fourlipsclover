package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction.TransactionStatus;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SettlementTransactionRepository extends
		JpaRepository<SettlementTransaction, Long> {

	List<SettlementTransaction> findBySettlement(Settlement settlement);

	int countAllBySettlement_Plan_PlanIdAndTransactionStatus(Integer planId, TransactionStatus transactionStatus);

	int countAllBySettlement_Plan_PlanId(Integer planId);
}
