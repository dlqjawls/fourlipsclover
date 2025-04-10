package com.patriot.fourlipsclover.analysis.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class ZeppelinService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${zeppelin.url}")
    private String zeppelinUrl;

    @Value("${zeppelin.notebook.id}")
    private String notebookId;

    @Value("${zeppelin.paragraph.id.analysis}")
    private String analysisParagraphId;

    /**
     * 제플린 노트북의 특정 파라그래프에서 그룹 ID를 변경하고 실행합니다.
     * @param groupId 설정할 그룹 ID
     * @return 성공 여부
     */
    public boolean runAnalysisForGroup(Long groupId) {
        try {
            // 1. 현재 파라그래프 코드 가져오기
            String paragraphUrl = String.format("%s/api/notebook/%s/paragraph/%s",
                    zeppelinUrl, notebookId, analysisParagraphId);

            ResponseEntity<String> getResponse = restTemplate.getForEntity(paragraphUrl, String.class);

            if (!getResponse.getStatusCode().is2xxSuccessful()) {
                log.error("파라그래프 조회 실패: {}", getResponse.getBody());
                return false;
            }

            // 2. 파라그래프 코드에서 그룹 ID 부분 찾아 변경
            JsonNode paragraphNode = objectMapper.readTree(getResponse.getBody());
            String originalText = paragraphNode.path("body").path("text").asText();

            // 정규식으로 val groupId = 숫자L 부분 찾아 교체
            Pattern pattern = Pattern.compile("val groupId = (\\d+)L");
            Matcher matcher = pattern.matcher(originalText);

            String modifiedText;
            if (matcher.find()) {
                modifiedText = originalText.replaceFirst(
                        "val groupId = \\d+L",
                        String.format("val groupId = %dL", groupId)
                );
            } else {
                log.error("그룹 ID 패턴을 찾을 수 없습니다");
                return false;
            }

            // 3. 변경된 코드로 파라그래프 업데이트
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> updateBody = new HashMap<>();
            updateBody.put("text", modifiedText);

            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(updateBody, headers);
            ResponseEntity<String> updateResponse = restTemplate.exchange(
                    paragraphUrl, HttpMethod.PUT, requestEntity, String.class);

            if (!updateResponse.getStatusCode().is2xxSuccessful()) {
                log.error("파라그래프 업데이트 실패: {}", updateResponse.getBody());
                return false;
            }

            log.info("그룹 ID {}로 파라그래프 코드 업데이트 성공", groupId);

            // 4. 파라그래프 실행
            String runUrl = String.format("%s/api/notebook/job/%s/%s",
                    zeppelinUrl, notebookId, analysisParagraphId);

            ResponseEntity<String> runResponse = restTemplate.postForEntity(
                    runUrl, new HttpEntity<>(headers), String.class);

            if (!runResponse.getStatusCode().is2xxSuccessful()) {
                log.error("파라그래프 실행 실패: {}", runResponse.getBody());
                return false;
            }

            log.info("그룹 ID {}에 대한 분석 작업 실행 성공", groupId);
            return true;

        } catch (Exception e) {
            log.error("제플린 노트북 실행 중 오류 발생", e);
            return false;
        }
    }

    /**
     * 제플린 노트북의 실행 상태를 확인합니다.
     * @return 실행 상태 (READY, RUNNING, FINISHED, ERROR)
     */
    public String getParagraphStatus() {
        try {
            String statusUrl = String.format("%s/api/notebook/%s/paragraph/%s",
                    zeppelinUrl, notebookId, analysisParagraphId);

            ResponseEntity<String> response = restTemplate.getForEntity(statusUrl, String.class);

            if (response.getStatusCode().is2xxSuccessful()) {
                JsonNode paragraphNode = objectMapper.readTree(response.getBody());
                return paragraphNode.path("body").path("status").asText("UNKNOWN");
            }

            return "ERROR";
        } catch (Exception e) {
            log.error("파라그래프 상태 확인 중 오류 발생", e);
            return "ERROR";
        }
    }
}