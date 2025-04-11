package com.patriot.fourlipsclover.analysis.controller;

import com.patriot.fourlipsclover.analysis.service.SpendingAnalysisService;
import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.member.entity.Member;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/spending-analysis")
public class SpendingAnalysisController {

    private final SpendingAnalysisService spendingAnalysisService;

    @GetMapping("/history")
    @Operation(
            summary = "사용자 소비 전체 내역 조회",
            description = "사용자의 소비 전체 내역을 날짜 범위로 필터링하여 조회합니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "400", description = "잘못된 요청"),
                    @ApiResponse(responseCode = "500", description = "서버 오류")
            }
    )
    public ResponseEntity<Map<String, Object>> getSpendingHistory(
            @Parameter(description = "시작 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "종료 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member member = userDetails.getMember();
        Long userId = member.getMemberId();

        // LocalDate를 LocalDateTime으로 변환 (시작일은 00:00:00, 종료일은 23:59:59)
        LocalDateTime startDateTime = startDate != null ?
                LocalDateTime.of(startDate, LocalTime.MIN) : null;
        LocalDateTime endDateTime = endDate != null ?
                LocalDateTime.of(endDate, LocalTime.MAX) : null;

        Map<String, Object> result = spendingAnalysisService.getUserSpendingHistory(
                userId, startDateTime, endDateTime);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/category")
    @Operation(
            summary = "카테고리별 지출 분석",
            description = "사용자의 카테고리별 지출 및 방문 데이터를 분석하여 반환합니다. 날짜 범위를 지정할 수 있습니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "분석 성공"),
                    @ApiResponse(responseCode = "400", description = "잘못된 요청"),
                    @ApiResponse(responseCode = "500", description = "서버 오류")
            }
    )
    public ResponseEntity<Map<String, Object>> getCategorySpending(
            @Parameter(description = "시작 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "종료 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member member = userDetails.getMember();
        Long userId = member.getMemberId();

        // LocalDate를 LocalDateTime으로 변환 (시작일은 00:00:00, 종료일은 23:59:59)
        LocalDateTime startDateTime = startDate != null ?
                LocalDateTime.of(startDate, LocalTime.MIN) : null;
        LocalDateTime endDateTime = endDate != null ?
                LocalDateTime.of(endDate, LocalTime.MAX) : null;

        Map<String, Object> result = spendingAnalysisService.analyzeSpendingByCategory(
                userId, startDateTime, endDateTime);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/group/category/{groupId}")
    @Operation(
            summary = "그룹 카테고리별 지출 분석",
            description = "그룹의 카테고리별 지출 및 방문 데이터를 분석하여 반환합니다. 날짜 범위를 지정할 수 있습니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "분석 성공"),
                    @ApiResponse(responseCode = "400", description = "잘못된 요청"),
                    @ApiResponse(responseCode = "500", description = "서버 오류")
            }
    )
    public ResponseEntity<Map<String, Object>> getGroupCategorySpending(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Parameter(description = "시작 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "종료 날짜 (yyyy-MM-dd)")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        // LocalDate를 LocalDateTime으로 변환 (시작일은 00:00:00, 종료일은 23:59:59)
        LocalDateTime startDateTime = startDate != null ?
                LocalDateTime.of(startDate, LocalTime.MIN) : null;
        LocalDateTime endDateTime = endDate != null ?
                LocalDateTime.of(endDate, LocalTime.MAX) : null;

        Map<String, Object> result = spendingAnalysisService.analyzeGroupSpendingByCategory(
                groupId, startDateTime, endDateTime);
        return ResponseEntity.ok(result);
    }

}