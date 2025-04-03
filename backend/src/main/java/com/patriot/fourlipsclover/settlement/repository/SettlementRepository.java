package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, Integer> {

	List<Settlement> plan(Plan plan);

	boolean existsByPlan_PlanId(Integer planId);
}
