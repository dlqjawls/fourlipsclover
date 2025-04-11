package com.patriot.fourlipsclover.analysis.kafka;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class GroupAnalysisKafkaListener {

    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "group-analysis-results", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(String message) {
        log.info("✅ [Kafka 수신] 분석 결과 메시지 수신: {}", message);

        try {
            JsonNode root = objectMapper.readTree(message);
            String analysisId = root.path("analysis_id").asText();
            long groupId = root.path("group_id").asLong();
            String timestamp = root.path("timestamp").asText();
            String analysisData = root.path("analysis_data").asText();

            log.info("📊 분석 ID: {}", analysisId);
            log.info("👥 그룹 ID: {}", groupId);
            log.info("🕒 타임스탬프: {}", timestamp);
            log.info("📈 분석 데이터: {}", analysisData);

            // ➕ 원하는 처리 추가: 예) DB 저장, 상태 업데이트 등
            // analysisService.save(analysisId, groupId, timestamp, analysisData);

        } catch (Exception e) {
            log.error("❌ Kafka 메시지 처리 중 오류 발생", e);
        }
    }
}

