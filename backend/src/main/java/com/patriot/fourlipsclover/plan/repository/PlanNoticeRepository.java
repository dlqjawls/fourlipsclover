package com.patriot.fourlipsclover.plan.repository;

import com.patriot.fourlipsclover.plan.entity.PlanNotice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlanNoticeRepository extends JpaRepository<PlanNotice, Integer> {

    // Plan에 속한 공지사항 목록 조회
    List<PlanNotice> findByPlan_PlanId(Integer planId);

    // PlanId 당 공지사항이 7개 이상인지 확인
    long countByPlan_PlanId(Integer planId);

    // 특정 planNoticeId로 공지사항 조회
    PlanNotice findByPlanNoticeId(Integer planNoticeId);

}
