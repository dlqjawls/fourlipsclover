package com.patriot.fourlipsclover.analysis.service;

import com.patriot.fourlipsclover.analysis.repository.SpendingAnalysisRepository;
import com.patriot.fourlipsclover.payment.entity.DataSource;
import com.patriot.fourlipsclover.payment.entity.VisitPayment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SpendingAnalysisService {

    private final SpendingAnalysisRepository spendingAnalysisRepository;

    /**
     * 사용자의 소비 전체 내역 조회
     * @param userId 사용자 ID
     * @param startDate 시작 날짜
     * @param endDate 종료 날짜
     * @return 소비 내역 목록과 요약 정보
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getUserSpendingHistory(Long userId, LocalDateTime startDate, LocalDateTime endDate) {
        // 날짜가 null이면 기본값 설정
        LocalDateTime effectiveStartDate = startDate != null ? startDate :
                LocalDateTime.of(2000, 1, 1, 0, 0);
        LocalDateTime effectiveEndDate = endDate != null ? endDate :
                LocalDateTime.now();

        List<VisitPayment> payments = spendingAnalysisRepository.findByUserIdAndPaidAtBetween(
                userId, effectiveStartDate, effectiveEndDate);

        // 간단한 지출 요약 정보 생성
        int totalAmount = payments.stream().mapToInt(VisitPayment::getAmount).sum();
        double avgAmount = payments.isEmpty() ? 0 : (double) totalAmount / payments.size();

        // 결과 맵 구성
        Map<String, Object> result = new HashMap<>();
        result.put("payments", payments);  // 전체 지출 내역
        result.put("totalPayments", payments.size());
        result.put("totalAmount", totalAmount);
        result.put("averageAmount", avgAmount);

        return result;
    }

    /**
     * 카테고리별 지출 패턴 분석
     * @param userId 사용자 ID
     * @param startDate 시작 날짜
     * @param endDate 종료 날짜
     * @return 카테고리별 지출 금액 맵
     */
    @Transactional(readOnly = true)
    public Map<String, Object> analyzeSpendingByCategory(Long userId, LocalDateTime startDate, LocalDateTime endDate) {
        // 날짜가 null이면 기본값 설정
        LocalDateTime effectiveStartDate = startDate != null ? startDate :
                LocalDateTime.of(2000, 1, 1, 0, 0);
        LocalDateTime effectiveEndDate = endDate != null ? endDate :
                LocalDateTime.now();

        // 최적화된 쿼리 사용
        List<Object[]> categoryData = spendingAnalysisRepository.findCategorySpendingSummary(
                userId, effectiveStartDate, effectiveEndDate);

        // 결과 맵 준비
        Map<String, Integer> categorySpending = new HashMap<>();
        Map<String, Integer> categoryVisits = new HashMap<>();
        int totalAmount = 0;
        int totalVisits = 0;

        // 쿼리 결과 처리
        for (Object[] data : categoryData) {
            String category = (String) data[0];
            Number amount = (Number) data[1];
            Number count = (Number) data[2];

            int amountValue = amount.intValue();
            int countValue = count.intValue();

            categorySpending.put(category, amountValue);
            categoryVisits.put(category, countValue);

            totalAmount += amountValue;
            totalVisits += countValue;
        }

        // 응답 맵 구성
        Map<String, Object> result = new HashMap<>();
        result.put("categorySpending", categorySpending);
        result.put("categoryVisits", categoryVisits);
        result.put("totalAmount", totalAmount);
        result.put("totalVisits", totalVisits);

        return result;
    }

}