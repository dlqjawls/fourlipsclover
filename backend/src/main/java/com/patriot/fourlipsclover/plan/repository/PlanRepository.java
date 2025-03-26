package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.plan.entity.Plan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PlanRepository extends JpaRepository<Plan, Integer> {

    @Query("SELECT p FROM Plan p WHERE p.group.groupId = :groupId")
    List<Plan> findPlansByGroupId(@Param("groupId") int groupId);  // Plan 엔티티만 반환

}