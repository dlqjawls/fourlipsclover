package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.settlement.entity.SettlementParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SettlementParticipantRepository extends
		JpaRepository<SettlementParticipant, Long> {

}
