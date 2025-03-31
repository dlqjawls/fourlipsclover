package com.patriot.fourlipsclover.match.controller;

import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.match.dto.request.LocalsProposalRequest;
import com.patriot.fourlipsclover.match.dto.request.MatchCreateRequest;
import com.patriot.fourlipsclover.match.dto.response.*;
import com.patriot.fourlipsclover.match.entity.Match;
import com.patriot.fourlipsclover.match.service.MatchService;
import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.repository.PaymentItemRepository;
import com.patriot.fourlipsclover.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/match")
public class MatchController {

    private final MatchService matchService;
    private final PaymentService paymentService;
    private final PaymentItemRepository paymentItemRepository;

    // 공통 인증 정보 추출 메서드
    private long getCurrentMemberId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        return userDetails.getMember().getMemberId();
    }

    // 매칭 생성 신청(신청서 validation 처리)
    @PostMapping("/create")
    public ResponseEntity<PaymentReadyResponse> createMatch(@RequestBody MatchCreateRequest request) {
        long currentMemberId = getCurrentMemberId();
        final Integer PAYMENT_ITEM_ID = 1;

        // 매칭 신청서 validation 처리
        matchService.validateMatchRequest(request, currentMemberId);

        // 최초 결제하기 버튼 (아이템명, 가격 등의 정보가 들어있는 결제하는 URL을 리턴해줌)
        PaymentReadyResponse paymentReadyResponse = paymentService.readyForMatch(
                String.valueOf(currentMemberId),
                PAYMENT_ITEM_ID
        );

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

    // 신청자 - 매칭 신청 내역 목록 조회(현지인 수락 상태 상관없이 전체 신청 목록 조회)
    @GetMapping
    public ResponseEntity<List<MatchListResponse>> getMatchList() {
        long currentMemberId = getCurrentMemberId();
        List<MatchListResponse> matchList = matchService.getMatchListByMemberId(currentMemberId);
        return ResponseEntity.ok(matchList);
    }

    // 신청자 - 매칭 신청 상세 조회
    @GetMapping("/{matchId}")
    public ResponseEntity<MatchDetailResponse> getMatchDetail(@PathVariable int matchId) {
        long currentMemberId = getCurrentMemberId();
        MatchDetailResponse matchDetail = matchService.getMatchDetail(matchId, currentMemberId);
        return ResponseEntity.ok(matchDetail);
    }

    // 신청자 - 매칭 결제 취소(현지인이 승낙 전이라면 결제 취소 처리 가능)
    @DeleteMapping("/delete/{matchId}")
    public ResponseEntity<Void> cancelMatch(@PathVariable int matchId) {
        long currentMemberId = getCurrentMemberId();
        matchService.cancelMatch(matchId, currentMemberId);
        return ResponseEntity.noContent().build();
    }

    // 현지인 - 매칭 신청 들어온 목록 조회
    @GetMapping("/guide")
    public ResponseEntity<List<LocalsMatchListResponse>> getMatchesForGuide() {
        long currentGuideId = getCurrentMemberId();
        List<LocalsMatchListResponse> guideMatches = matchService.getLocalsMatchListByGuideId(currentGuideId);
        return ResponseEntity.ok(guideMatches);
    }

    // 현지인 - 매칭 수락(PENDING -> CONFIRMED)
    @PutMapping("/guide/confirm/{matchId}")
    public ResponseEntity<LocalsConfirmResponse> acceptMatch(@PathVariable int matchId) {
        long currentMemberId = getCurrentMemberId();
        LocalsConfirmResponse match = matchService.processAcceptMatch(matchId, currentMemberId);
        return ResponseEntity.ok(match);
    }

    // 현지인 - CONFIRMED 상태인 매칭 목록 조회
    @GetMapping("/guide/confirmed")
    public ResponseEntity<List<LocalsMatchListResponse>> getMatchesForGuideConfirmed() {
        long currentGuideId = getCurrentMemberId();
        List<LocalsMatchListResponse> guideMatches = matchService.getConfirmedMatchesForGuide(currentGuideId);
        return ResponseEntity.ok(guideMatches);
    }

    // 현지인 - CONFIRMED 상태인 매칭에 대해 기획서 작성
    @PostMapping("/guide/proposal")
    public ResponseEntity<LocalsProposalResponse> createLocalsProposal(@RequestBody LocalsProposalRequest request) {
        long currentMemberId = getCurrentMemberId();
        LocalsProposalResponse proposal = matchService.createLocalsProposal(request, currentMemberId);
        return ResponseEntity.ok(proposal);
    }

    // 현지인 - 매칭 거절 및 결제 취소 API
    @PutMapping("/guide/reject/{matchId}")
    public ResponseEntity<String> rejectMatch(@PathVariable int matchId) {
        long currentMemberId = getCurrentMemberId();
        matchService.rejectMatch(matchId, currentMemberId);
        return ResponseEntity.ok("매칭 거절 및 결제 취소 완료");
    }

    // 현지인 - 기획서 작성 완료된 매칭에 대해 채팅방 생성(세션기간 1일)


}

