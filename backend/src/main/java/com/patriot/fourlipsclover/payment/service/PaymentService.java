package com.patriot.fourlipsclover.payment.service;

import com.patriot.fourlipsclover.exception.PaymentNotFoundException;
import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentCancelResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.entity.*;
import com.patriot.fourlipsclover.payment.mapper.PaymentMapper;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import com.patriot.fourlipsclover.payment.repository.PaymentItemRepository;
import com.patriot.fourlipsclover.payment.repository.VisitPaymentRepository;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanSchedule;
import com.patriot.fourlipsclover.plan.repository.PlanScheduleRepository;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import com.patriot.fourlipsclover.settlement.entity.Expense;
import com.patriot.fourlipsclover.settlement.entity.ExpenseParticipant;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.exception.SettlementNotFoundException;
import com.patriot.fourlipsclover.settlement.repository.ExpenseParticipantRepository;
import com.patriot.fourlipsclover.settlement.repository.ExpenseRepository;
import com.patriot.fourlipsclover.settlement.repository.SettlementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentItemRepository paymentItemRepository;
    private final RestaurantService restaurantService;
    private final VisitPaymentRepository visitPaymentRepository;
    private final SettlementRepository settlementRepository;
    private final ExpenseRepository expenseRepository;
    private final ExpenseParticipantRepository expenseParticipantRepository;
    private final PlanScheduleRepository planScheduleRepository;

    private static final String KAKAO_PAY_READY_URL = "https://open-api.kakaopay.com/online/v1/payment/ready";
    private static final String KAKAO_PAY_APPROVE_URL = "https://open-api.kakaopay.com/online/v1/payment/approve";
    private static final String KAKAO_PAY_CANCEL = "https://open-api.kakaopay.com/online/v1/payment/cancel";
    private final PaymentApprovalRepository paymentApprovalRepository;
    private final PaymentMapper paymentMapper;
    private final String CID = "TC0ONETIME";
    @Value("${kakao.payment.admin-key}")
    private String ADMIN_KEY;

    @Transactional
    public PaymentReadyResponse ready(String userId, String itemName,
                                      String quantity, String totalAmount) {
        RestTemplate restTemplate = new RestTemplate();
        String orderId = UUID.randomUUID().toString();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> params = new HashMap<>();
        params.put("cid", CID);
        params.put("partner_order_id", orderId);
        params.put("partner_user_id", userId);
        params.put("item_name", itemName);
        params.put("quantity", quantity);
        params.put("total_amount", totalAmount);
        params.put("tax_free_amount", 0);
        params.put("approval_url", "https://fourlipsclover.duckdns.org/api/payment/approve");
        params.put("cancel_url", "https://fourlipsclover.duckdns.org/api/payment/cancel");
        params.put("fail_url", "https://fourlipsclover.duckdns.org/api/payment/fail");

        HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
        ResponseEntity<PaymentReadyResponse> responseEntity = restTemplate.postForEntity(
                KAKAO_PAY_READY_URL, requestEntity, PaymentReadyResponse.class);
        PaymentReadyResponse response = responseEntity.getBody();
        response.setOrderId(orderId);
        System.out.println(response);

        return response;
    }

    @Transactional
    public PaymentReadyResponse readyForMatch(Long currentMemberId,
                                              Integer itemId) {
        RestTemplate restTemplate = new RestTemplate();
        String orderId = UUID.randomUUID().toString();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 상품 정보 조회
        PaymentItem paymentItem = paymentItemRepository.findByPaymentItemId(itemId)
                .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다."));

        String itemName = paymentItem.getItemName();
        Integer quantity = Integer.parseInt(paymentItem.getQuantity());  // quantity는 정수로 처리
        String totalAmount = paymentItem.getTotalAmount(); // 금액은 문자열로 처리

        Map<String, Object> params = new HashMap<>();
        params.put("cid", CID);
        params.put("partner_order_id", orderId);
        params.put("partner_user_id", currentMemberId);
        params.put("item_name", itemName);
        params.put("quantity", quantity);
        params.put("total_amount", totalAmount);
        params.put("tax_free_amount", 0);
        params.put("approval_url", "https://fourlipsclover.duckdns.org/api/payment/approve");
        params.put("cancel_url", "https://fourlipsclover.duckdns.org/api/payment/cancel");
        params.put("fail_url", "https://fourlipsclover.duckdns.org/api/payment/fail");

        HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
        ResponseEntity<PaymentReadyResponse> responseEntity = restTemplate.postForEntity(
                KAKAO_PAY_READY_URL, requestEntity, PaymentReadyResponse.class);

        PaymentReadyResponse response = responseEntity.getBody();
        response.setOrderId(orderId);
        response.setItemName(itemName);
        response.setQuantity(String.valueOf(quantity));
        response.setTotalAmount(totalAmount);

        return response;
    }

    @Transactional
    public PaymentApproveResponse approve(String tid, String pgToken, String orderId, String userId,
                                          int amount) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> params = new HashMap<>();
        params.put("cid", CID);
        params.put("tid", tid);
        params.put("partner_order_id", orderId);
        params.put("partner_user_id", userId);
        params.put("pg_token", pgToken);
        params.put("total_amount", String.valueOf(amount));

        HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
        ResponseEntity<PaymentApproveResponse> responseEntity = restTemplate.postForEntity(
                KAKAO_PAY_APPROVE_URL, requestEntity, PaymentApproveResponse.class);
        PaymentApproveResponse response = responseEntity.getBody();
        if (Objects.isNull(response)) {
            throw new IllegalArgumentException("존재하지 않는 거래입니다.");
        }
        PaymentApproval paymentApproval = paymentMapper.toEntity(response);
        paymentApproval.setStatus(PaymentStatus.APPROVED);
        paymentApprovalRepository.save(paymentApproval);
        return responseEntity.getBody();
    }

    @Transactional
    public PaymentCancelResponse cancel(String cid, String tid, Integer cancelAmount,
                                        Integer cancelTaxFreeAmount) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> params = new HashMap<>();

        params.put("cid", cid);
        params.put("tid", tid);
        params.put("cancel_amount", cancelAmount);
        params.put("cancel_tax_free_amount", cancelTaxFreeAmount);

        HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
        ResponseEntity<PaymentCancelResponse> responseEntity = restTemplate.postForEntity(
                KAKAO_PAY_CANCEL, requestEntity, PaymentCancelResponse.class);
        PaymentApproval paymentApproval = paymentApprovalRepository.findByTid(tid).orElseThrow(() -> new PaymentNotFoundException("존재하지 않는 결제 정보 입니다."));
        paymentApproval.setStatus(PaymentStatus.CANCELED);
        return responseEntity.getBody();
    }

    @Transactional(readOnly = true)
    public List<PaymentApproveResponse> findById(Long memberId) {
        List<PaymentApproval> paymentApprovals = paymentApprovalRepository.findByPartnerUserId(
                String.valueOf(memberId));
        return paymentApprovals.stream().map(paymentMapper::toDto).toList();
    }

    @Transactional
    public void createVisitPaymentsFromSettlement(Integer settlementId) {
        // 정산 정보 조회
        Settlement settlement = settlementRepository.findById(settlementId)
                .orElseThrow(() -> new SettlementNotFoundException(settlementId));

        Plan plan = settlement.getPlan();

        // 해당 플랜의 일정(schedules) 조회
        List<PlanSchedule> planSchedules = planScheduleRepository.findByPlanAndVisitAtBetween(
                plan,
                plan.getStartDate().atStartOfDay(),
                plan.getEndDate().plusDays(1).atStartOfDay().minusSeconds(1)
        );

        // 해당 정산의 모든 지출 항목 조회
        List<Expense> expenses = expenseRepository.findBySettlement(settlement);

        for (Expense expense : expenses) {
            PaymentApproval paymentApproval = expense.getPaymentApproval();

            // 참가자 수 계산
            List<ExpenseParticipant> participants = expenseParticipantRepository.findByExpense(expense);
            int visitedPersonnel = participants.size();

            // 결제 시간과 가장 가까운 일정을 찾아 해당 Restaurant 정보 사용
            Restaurant restaurant = findNearestScheduleRestaurant(planSchedules, paymentApproval.getApprovedAt());

            // 식당 정보를 찾을 수 없는 경우 처리
            if (restaurant == null) {
                // 로그 기록 또는 스킵
                continue;
            }

            // VisitPayment 생성
            VisitPayment visitPayment = VisitPayment.builder()
                    .restaurantId(restaurant)
                    .userId(Long.parseLong(paymentApproval.getPartnerUserId()))
                    .dataSource(DataSource.group)
                    .visitedPersonnel(visitedPersonnel)
                    .amount(paymentApproval.getAmount().getTotal())
                    .paidAt(paymentApproval.getApprovedAt())
                    .createdAt(LocalDateTime.now())
                    .build();

            visitPaymentRepository.save(visitPayment);
        }
    }

    /**
     * 결제 시간과 가장 가까운 일정의 Restaurant 정보를 찾습니다.
     */
    private Restaurant findNearestScheduleRestaurant(List<PlanSchedule> planSchedules, LocalDateTime paymentTime) {
        if (planSchedules.isEmpty()) {
            return null;
        }

        return planSchedules.stream()
                .min((s1, s2) -> {
                    long diff1 = Math.abs(Duration.between(paymentTime, s1.getVisitAt()).toMinutes());
                    long diff2 = Math.abs(Duration.between(paymentTime, s2.getVisitAt()).toMinutes());
                    return Long.compare(diff1, diff2);
                })
                .map(PlanSchedule::getRestaurant)
                .orElse(null);
    }

}
