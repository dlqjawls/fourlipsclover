package com.patriot.fourlipsclover.analysis.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class GroupAnalysisConsumerService {

    // 그룹별, 분석 유형별 최신 분석 결과 저장 (중첩 맵 구조)
    private final Map<Long, Map<String, Object>> groupAnalysisCache = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "group-analysis-results", groupId = "analysis-consumer-group")
    public void consumeAnalysisResults(String message) {
        try {
            // JSON 메시지를 맵으로 변환
            Map<String, Object> resultMap = objectMapper.readValue(message, HashMap.class);

            // 그룹 ID와 분석 ID 추출
            Long groupId = Long.valueOf(resultMap.get("group_id").toString());
            String analysisId = resultMap.get("analysis_id").toString();

            // 해당 그룹의 캐시 맵 가져오거나 생성
            groupAnalysisCache.computeIfAbsent(groupId, k -> new ConcurrentHashMap<>());

            // 해당 분석 유형의 결과를 저장
            groupAnalysisCache.get(groupId).put(analysisId, resultMap);

            log.info("그룹 {}의 {} 분석 결과 수신 완료", groupId, analysisId);
        } catch (Exception e) {
            log.error("분석 결과 처리 중 오류 발생", e);
        }
    }

    // 특정 그룹의 모든 분석 결과 조회
    public Map<String, Object> getGroupAnalysisResult(Long groupId) {
        Map<String, Object> result = groupAnalysisCache.get(groupId);
        if (result == null || result.isEmpty()) {
            return new HashMap<>();
        }

        // 모든 분석 유형을 하나의 응답으로 통합
        Map<String, Object> combinedResult = new HashMap<>();
        combinedResult.put("group_id", groupId);
        combinedResult.put("analyses", result);

        return combinedResult;
    }

    // 특정 그룹의 특정 분석 유형 결과 조회
    public Map<String, Object> getGroupAnalysisResultByType(Long groupId, String analysisType) {
        Map<String, Object> groupResults = groupAnalysisCache.get(groupId);
        if (groupResults == null || !groupResults.containsKey(analysisType)) {
            return new HashMap<>();
        }

        return (Map<String, Object>) groupResults.get(analysisType);
    }

    // 모든 그룹의 분석 결과 조회
    public Map<Long, Map<String, Object>> getAllGroupAnalysisResults() {
        return new HashMap<>(groupAnalysisCache);
    }
}