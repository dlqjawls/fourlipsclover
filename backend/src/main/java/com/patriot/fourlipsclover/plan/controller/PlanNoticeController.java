package com.patriot.fourlipsclover.plan.controller;

import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.plan.dto.request.PlanNoticeRequest;
import com.patriot.fourlipsclover.plan.dto.response.PlanNoticeResponse;
import com.patriot.fourlipsclover.plan.service.PlanNoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/plan-notice")
public class PlanNoticeController {

    private final PlanNoticeService planNoticeService;

    // 공통 인증 정보 추출 메서드
    private long getCurrentMemberId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        return userDetails.getMember().getMemberId();
    }

    // 공지사항 생성
    @PostMapping("/create/{planId}")
    public ResponseEntity<PlanNoticeResponse> createPlanNotice(@PathVariable Integer planId,
                                                               @RequestBody PlanNoticeRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanNoticeResponse response = planNoticeService.createPlanNotice(planId, currentMemberId, request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // 특정 Plan의 모든 공지사항 조회
    @GetMapping("/list/{planId}")
    public ResponseEntity<List<PlanNoticeResponse>> getPlanNotices(@PathVariable Integer planId) {
        long currentMemberId = getCurrentMemberId();
        List<PlanNoticeResponse> response = planNoticeService.getPlanNotices(planId, currentMemberId);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // 공지사항 수정
    @PutMapping("/update/{planNoticeId}")
    public ResponseEntity<PlanNoticeResponse> updatePlanNotice(@PathVariable Integer planNoticeId,
                                                               @RequestBody PlanNoticeRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanNoticeResponse response = planNoticeService.updatePlanNotice(planNoticeId, currentMemberId, request);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // 공지사항 삭제
    @DeleteMapping("/delete/{planNoticeId}")
    public ResponseEntity<Void> deletePlanNotice(@PathVariable Integer planNoticeId) {
        long currentMemberId = getCurrentMemberId();
        planNoticeService.deletePlanNotice(planNoticeId, currentMemberId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }


}
