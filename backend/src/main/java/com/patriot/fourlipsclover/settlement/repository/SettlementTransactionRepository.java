package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SettlementTransactionRepository extends
		JpaRepository<SettlementTransaction, Long> {

	List<SettlementTransaction> findBySettlement(Settlement settlement);
}
