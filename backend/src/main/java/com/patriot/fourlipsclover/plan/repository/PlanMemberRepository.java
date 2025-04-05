package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.entity.PlanMemberId;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlanMemberRepository extends JpaRepository<PlanMember, PlanMemberId> {

	boolean existsByPlan_PlanIdAndMember_MemberId(Integer planId, Long memberId);

	List<PlanMember> findByPlan_PlanId(Integer planId);

	void deleteByPlan_PlanId(int planId);

	Integer plan(Plan plan);
}
