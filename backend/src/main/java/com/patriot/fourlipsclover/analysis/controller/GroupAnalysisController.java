package com.patriot.fourlipsclover.analysis.controller;

import com.patriot.fourlipsclover.analysis.service.GroupAnalysisConsumerService;
import com.patriot.fourlipsclover.analysis.service.ZeppelinService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/analysis")
public class GroupAnalysisController {

    private final GroupAnalysisConsumerService groupAnalysisConsumerService;
    private final ZeppelinService zeppelinService;

    @GetMapping("/group/{groupId}")
    @Operation(
            summary = "그룹 소비 분석 결과 조회",
            description = "특정 그룹의 소비 패턴 분석 결과를 조회합니다. 결과가 없으면 분석을 요청합니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "202", description = "분석 중"),
                    @ApiResponse(responseCode = "404", description = "분석 결과 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 오류")
            }
    )
    public ResponseEntity<Map<String, Object>> getGroupAnalysis(@PathVariable Long groupId) {
        // 1. 캐시에서 분석 결과 확인
        Map<String, Object> result = groupAnalysisConsumerService.getGroupAnalysisResult(groupId);

        if (!result.isEmpty()) {
            // 분석 결과가 있으면 바로 반환
            return ResponseEntity.ok(result);
        }

        // 2. 분석 결과가 없으면 제플린 분석 작업 실행 요청
        boolean analysisRequested = zeppelinService.runAnalysisForGroup(groupId);

        if (analysisRequested) {
            // 분석 요청 성공 - 처리 중 상태 반환
            Map<String, Object> processingResponse = new HashMap<>();
            processingResponse.put("message", "분석이 진행 중입니다. 잠시 후 다시 시도해주세요.");
            processingResponse.put("group_id", groupId);
            processingResponse.put("status", "PROCESSING");

            return ResponseEntity.accepted().body(processingResponse);
        } else {
            // 분석 요청 실패
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", "분석 요청 처리에 실패했습니다.");
            errorResponse.put("group_id", groupId);
            errorResponse.put("status", "ERROR");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @GetMapping("/group/{groupId}/{analysisType}")
    @Operation(
            summary = "그룹의 특정 유형 분석 결과 조회",
            description = "그룹의 특정 분석 유형(basic_comparison, personnel_comparison, time_comparison, day_of_week_comparison) 결과를 조회합니다.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "404", description = "분석 결과 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 오류")
            }
    )
    public ResponseEntity<Map<String, Object>> getGroupAnalysisByType(
            @PathVariable Long groupId,
            @PathVariable String analysisType) {

        Map<String, Object> result = groupAnalysisConsumerService.getGroupAnalysisResultByType(groupId, analysisType);

        if (result.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(result);
    }

}