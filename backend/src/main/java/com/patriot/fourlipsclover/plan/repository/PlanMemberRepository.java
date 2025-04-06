package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.entity.PlanMemberId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PlanMemberRepository extends JpaRepository<PlanMember, PlanMemberId> {

    boolean existsByPlan_PlanIdAndMember_MemberId(Integer planId, Long memberId);

    List<PlanMember> findByPlan_PlanId(Integer planId);

    void deleteByPlan_PlanId(int planId);

    Optional<Object> findByPlan_PlanIdAndMember_MemberId(Integer planId, long currentMemberId);

    Integer plan(Plan plan);

    long countByPlan_PlanId(Integer planId);
}
