package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.entity.PlanMemberId;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PlanMemberRepository extends JpaRepository<PlanMember, PlanMemberId> {

    boolean existsByPlan_PlanIdAndMember_MemberId(Integer planId, Long memberId);

    List<PlanMember> findByPlan_PlanId(Integer planId);

    void deleteByPlan_PlanId(int planId);

    Optional<Object> findByPlan_PlanIdAndMember_MemberId(Integer planId, long currentMemberId);

    Integer plan(Plan plan);

    long countByPlan_PlanId(Integer planId);

	List<PlanMember> findByMember(Member member);

    @Query("SELECT pm FROM PlanMember pm WHERE pm.member = :member AND pm.plan.startDate <= :today AND pm.plan.endDate >= :today")
    List<PlanMember> findCurrentPlansByMember(@Param("member") Member member, @Param("today") LocalDate today);
}
