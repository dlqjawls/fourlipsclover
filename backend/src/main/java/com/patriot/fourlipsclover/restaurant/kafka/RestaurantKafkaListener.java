package com.patriot.fourlipsclover.restaurant.kafka;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.restaurant.dto.kafka.RestaurantKafkaDto;
import com.patriot.fourlipsclover.restaurant.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RestaurantKafkaListener {

    private final RestaurantService restaurantService;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "mysql-server.fourlipsclover.restaurant", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(ConsumerRecord<String, String> record) {
        try {
            String message = record.value();
            log.info("Received message from Kafka: {}", message);

            // 메시지를 먼저 JsonNode로 파싱
            JsonNode rootNode = objectMapper.readTree(message);

            // 필요한 데이터 추출
            JsonNode payloadNode = rootNode.path("payload");
            if (payloadNode.isMissingNode()) {
                log.warn("Payload node is missing in Kafka message");
                return;
            }

            // 작업 유형 추출
            String operation = "r"; // 기본값
            if (!payloadNode.path("op").isMissingNode()) {
                operation = payloadNode.path("op").asText();
            }

            JsonNode afterNode = payloadNode.path("after");
            if (afterNode == null || afterNode.isMissingNode() || afterNode.isNull()) {
                log.warn("After node is missing or null in Kafka message");
                return;
            }

            // 레스토랑 ID 확인
            if (!afterNode.has("restaurant_id") || afterNode.get("restaurant_id").isNull()) {
                log.warn("restaurant_id is missing or null in Kafka message");
                return;
            }

            try {
                // afterNode에서 필요한 필드 추출해서 DTO 생성
                RestaurantKafkaDto restaurantDto = objectMapper.treeToValue(afterNode, RestaurantKafkaDto.class);

                // 작업 유형 설정
                restaurantDto.setOp(operation);

                // ID 필드 다시 확인
                if (restaurantDto.getRestaurantId() == null) {
                    restaurantDto.setRestaurantId(afterNode.path("restaurant_id").asInt());
                }

                // null 필드에 기본값 설정
                if (restaurantDto.getPlaceName() == null) {
                    restaurantDto.setPlaceName(""); // 빈 문자열 기본값
                }

                if (restaurantDto.getKakaoPlaceId() == null && afterNode.has("kakao_place_id")) {
                    restaurantDto.setKakaoPlaceId(afterNode.path("kakao_place_id").asText(""));
                }

                // 서비스를 통해 처리
                restaurantService.processKafkaMessage(restaurantDto);
            } catch (Exception e) {
                log.error("Failed to convert JSON to DTO: {}", e.getMessage());

                // 수동으로 DTO 생성 시도
                RestaurantKafkaDto restaurantDto = new RestaurantKafkaDto();
                restaurantDto.setOp(operation);
                restaurantDto.setRestaurantId(afterNode.path("restaurant_id").asInt());

                // 다른 필드들도 수동으로 설정
                if (afterNode.has("place_name")) {
                    restaurantDto.setPlaceName(afterNode.path("place_name").asText(""));
                }
                if (afterNode.has("kakao_place_id")) {
                    restaurantDto.setKakaoPlaceId(afterNode.path("kakao_place_id").asText(""));
                }
                if (afterNode.has("food_category_id") && !afterNode.path("food_category_id").isNull()) {
                    restaurantDto.setFoodCategoryId(afterNode.path("food_category_id").asInt());
                }

                restaurantService.processKafkaMessage(restaurantDto);
            }

        } catch (Exception e) {
            log.error("Error processing Kafka message for restaurant: {}", e.getMessage(), e);
        }
    }
}