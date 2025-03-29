package com.patriot.fourlipsclover.match.controller;

import com.patriot.fourlipsclover.chat.service.ChatService;
import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.match.dto.request.MatchCreateRequest;
import com.patriot.fourlipsclover.match.entity.Match;
import com.patriot.fourlipsclover.match.service.MatchService;
import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.service.PaymentService;
import com.patriot.fourlipsclover.plan.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/match")
public class MatchController {

    private final MatchService matchService;
    private final ChatService chatService;
    private final PlanService planService;
    private final PaymentService paymentService;

    // 공통 인증 정보 추출 메서드
    private long getCurrentMemberId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        return userDetails.getMember().getMemberId();
    }

    // 매칭 생성 신청(validation 처리)
    @PostMapping("/create")
    public ResponseEntity<PaymentReadyResponse> createMatch(@RequestBody MatchCreateRequest request) {
        long currentMemberId = getCurrentMemberId();

        matchService.validateMatchRequest(request, currentMemberId);

        // 최초 결제 하기 버튼 (아이템명, 가격 등의 정보가 들어있는 결제하는 URL을 리턴해줌)
        // 상품명, 수량, 결제비용 등은 리팩토링시 테이블 따로 뺼 예정
        PaymentReadyResponse paymentReadyResponse = paymentService.ready(
                String.valueOf(currentMemberId),
                "매칭 비용",  // 상품명
                "1",  // 수량
                "2000"  // 결제비용
        );

        // 결제 URL을 반환해주면, 클라이언트는 해당 URL로 리디렉션하여 결제 진행
        return ResponseEntity.ok(paymentReadyResponse);
    }

    // /create를 통해 리턴받은 url 접속 후의 결제하기 버튼
    @PostMapping("/approve")
    public ResponseEntity<PaymentApproveResponse> approve(
            @RequestParam String tid,
            @RequestParam String pgToken,
            @RequestParam String orderId,
            @RequestParam String userId,
            @RequestParam int amount,
            @RequestBody MatchCreateRequest request) {

        long currentMemberId = getCurrentMemberId();

        // 결제 승인 처리
        PaymentApproveResponse paymentApproveResponse = paymentService.approve(
                tid, pgToken, orderId, userId, amount);

        // 결제 승인 성공 후, Match 엔티티에 partnerOrderId를 저장
        String partnerOrderId = paymentApproveResponse.getPartnerOrderId();
        Match createdMatch = matchService.createMatchAfterPayment(partnerOrderId, request, currentMemberId);

        return ResponseEntity.ok(paymentApproveResponse);
    }

}

