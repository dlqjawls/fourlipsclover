package com.patriot.fourlipsclover.analysis.repository;

import com.patriot.fourlipsclover.payment.entity.DataSource;
import com.patriot.fourlipsclover.payment.entity.VisitPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SpendingAnalysisRepository extends JpaRepository<VisitPayment, Integer> {

    // 특정 사용자의 지출 내역 조회
    List<VisitPayment> findByUserId(Long userId);

    // 특정 기간 내 사용자의 지출 내역 조회
    List<VisitPayment> findByUserIdAndPaidAtBetween(
            Long userId, LocalDateTime startDate, LocalDateTime endDate);

    // 카테고리별 지출 요약을 위한 JPQL 쿼리 (최적화)
    @Query("SELECT r.foodCategory.name as category, SUM(v.amount) as total, COUNT(v) as count " +
            "FROM VisitPayment v JOIN v.restaurantId r " +
            "WHERE v.userId = :userId AND v.paidAt BETWEEN :startDate AND :endDate " +
            "GROUP BY r.foodCategory.name")
    List<Object[]> findCategorySpendingSummary(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
}