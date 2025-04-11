package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface PlanScheduleRepository extends JpaRepository<PlanSchedule, Integer> {

    List<PlanSchedule> findByPlan(Plan plan);

    void deleteByPlan_PlanId(Integer planId);

    List<PlanSchedule> findByPlanAndVisitAtBetween(Plan plan, LocalDateTime start, LocalDateTime end);
}
