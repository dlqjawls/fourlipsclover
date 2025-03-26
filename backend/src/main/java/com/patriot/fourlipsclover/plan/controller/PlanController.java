package com.patriot.fourlipsclover.plan.controller;

import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.group.repository.GroupRepository;
import com.patriot.fourlipsclover.plan.dto.request.PlanCreateRequest;
import com.patriot.fourlipsclover.plan.dto.request.PlanScheduleCreateRequest;
import com.patriot.fourlipsclover.plan.dto.request.PlanScheduleUpdateRequest;
import com.patriot.fourlipsclover.plan.dto.request.PlanUpdateRequest;
import com.patriot.fourlipsclover.plan.dto.response.*;
import com.patriot.fourlipsclover.plan.entity.PlanSchedule;
import com.patriot.fourlipsclover.plan.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/group/{groupId}/plan")
public class PlanController {

    private final PlanService planService;
    private final GroupRepository groupRepository;

    // 공통 인증 정보 추출 메서드
    private long getCurrentMemberId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        return userDetails.getMember().getMemberId();
    }

    // 소속 그룹에서 계획 생성
    @PostMapping("/create")
    public ResponseEntity<PlanResponse> createPlan(@PathVariable int groupId,
                                                   @RequestBody PlanCreateRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanResponse planResponse = planService.createPlan(groupId, request, currentMemberId);
        return ResponseEntity.status(HttpStatus.CREATED).body(planResponse);
    }

    // 소속된 그룹의 계획 목록 조회
    @GetMapping
    public ResponseEntity<List<PlanListResponse>> getPlans(@PathVariable int groupId) {
        long currentMemberId = getCurrentMemberId();
        List<PlanListResponse> plans = planService.getPlansByGroup(groupId, currentMemberId);
        return ResponseEntity.ok(plans);
    }

    // 소속된 계획 상세 조회
    @GetMapping("/{planId}")
    public ResponseEntity<PlanDetailResponse> getPlan(@PathVariable int groupId,
                                                      @PathVariable int planId) {
        long currentMemberId = getCurrentMemberId();
        PlanDetailResponse planResponse = planService.getPlanById(planId, groupId, currentMemberId);
        return ResponseEntity.ok(planResponse);
    }

    // 소속된 계획 수정
    @PutMapping("/update/{planId}")
    public ResponseEntity<PlanResponse> updatePlan(@PathVariable int groupId,
                                                   @PathVariable int planId,
                                                   @RequestBody PlanUpdateRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanResponse updatedPlan = planService.updatePlan(groupId, planId, request, currentMemberId);
        return ResponseEntity.ok(updatedPlan);
    }

    // 소속된 계획 삭제
    @DeleteMapping("/delete/{planId}")
    public ResponseEntity<Void> deletePlan(@PathVariable int groupId,
                                           @PathVariable int planId) {
        long currentMemberId = getCurrentMemberId();
        planService.deletePlan(groupId, planId, currentMemberId);
        return ResponseEntity.noContent().build();
    }

    // 계획-일정 생성
    @PostMapping("/{planId}/schedule/create")
    public ResponseEntity<PlanSchedule> createPlanSchedule(@PathVariable int planId,
                                                           @RequestBody PlanScheduleCreateRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanSchedule planSchedule = planService.createPlanSchedule(planId, request, currentMemberId);
        return ResponseEntity.status(HttpStatus.CREATED).body(planSchedule);
    }

    // 계획-일정 목록 조회
    @GetMapping("/{planId}/schedule")
    public ResponseEntity<List<PlanScheduleResponse>> getPlanSchedules(@PathVariable int planId) {
        long currentMemberId = getCurrentMemberId();
        List<PlanScheduleResponse> schedules = planService.getPlanSchedules(planId, currentMemberId);
        return ResponseEntity.ok(schedules);
    }

    // 계획-일정 상세 조회
    @GetMapping("/{planId}/schedule/{scheduleId}")
    public ResponseEntity<PlanScheduleDetailResponse> getPlanSchedule(@PathVariable int scheduleId) {
        long currentMemberId = getCurrentMemberId();
        PlanScheduleDetailResponse scheduleResponse = planService.getPlanSchedule(scheduleId, currentMemberId);
        return ResponseEntity.ok(scheduleResponse);
    }

    // 계획-일정 수정 (방문 날짜 혹은 시간)
    @PutMapping("/{planId}/schedule/update/{scheduleId}")
    public ResponseEntity<PlanScheduleUpdateResponse> updatePlanSchedule(@PathVariable int scheduleId,
                                                                         @RequestBody PlanScheduleUpdateRequest request) {
        long currentMemberId = getCurrentMemberId();
        PlanScheduleUpdateResponse updatedSchedule = planService.updatePlanSchedule(scheduleId, request, currentMemberId);
        return ResponseEntity.ok(updatedSchedule);
    }

    // 계획-일정 삭제
    @DeleteMapping("/{planId}/schedule/delete/{scheduleId}")
    public ResponseEntity<Void> deletePlanSchedule(@PathVariable int scheduleId) {
        long currentMemberId = getCurrentMemberId();
        planService.deletePlanSchedule(scheduleId, currentMemberId);
        return ResponseEntity.noContent().build();
    }
}
