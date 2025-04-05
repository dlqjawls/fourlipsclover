package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SettlementTransactionRepository extends
		JpaRepository<SettlementTransaction, Long> {

}
