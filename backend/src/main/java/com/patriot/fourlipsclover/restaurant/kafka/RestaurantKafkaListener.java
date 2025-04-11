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
            log.info("Full Kafka Message: {}", message);

            // 메시지를 먼저 JsonNode로 파싱
            JsonNode rootNode = objectMapper.readTree(message);

            // 필요한 데이터 추출
            JsonNode payloadNode = rootNode.path("payload");
            if (payloadNode.isMissingNode()) {
                log.warn("Payload node is missing in Kafka message");
                return;
            }

            // 작업 유형 추출
            String operation = payloadNode.path("op").asText("r"); // 기본값 'r'

            JsonNode afterNode = payloadNode.path("after");
            if (afterNode.isMissingNode() || afterNode.isNull()) {
                log.warn("After node is missing or null in Kafka message");
                return;
            }

            // 레스토랑 ID 확인
            if (!afterNode.has("restaurant_id") || afterNode.get("restaurant_id").isNull()) {
                log.warn("restaurant_id is missing or null in Kafka message");
                return;
            }

            // 로그 추가: AfterNode 상세 내용 출력
            log.info("AfterNode Details: {}", afterNode.toString());

            RestaurantKafkaDto restaurantDto = createRestaurantDto(afterNode, operation);

            // 서비스를 통해 처리
            restaurantService.processKafkaMessage(restaurantDto);

        } catch (Exception e) {
            log.error("Error processing Kafka message for restaurant: {}", e.getMessage(), e);
        }
    }

    private RestaurantKafkaDto createRestaurantDto(JsonNode afterNode, String operation) {
        RestaurantKafkaDto restaurantDto = new RestaurantKafkaDto();

        // 작업 유형 설정
        restaurantDto.setOp(operation);

        // 각 필드 안전하게 설정
        setIfExists(afterNode, "restaurant_id", id -> restaurantDto.setRestaurantId(id.asInt()));
        setIfExists(afterNode, "place_name", name -> restaurantDto.setPlaceName(name.asText("")));
        setIfExists(afterNode, "address_name", addr -> restaurantDto.setAddressName(addr.asText("")));
        setIfExists(afterNode, "road_address_name", roadAddr -> restaurantDto.setRoadAddressName(roadAddr.asText("")));
        setIfExists(afterNode, "category_name", category -> restaurantDto.setCategoryName(category.asText("")));
        setIfExists(afterNode, "phone", phone -> restaurantDto.setPhone(phone.asText("")));
        setIfExists(afterNode, "place_url", url -> restaurantDto.setPlaceUrl(url.asText("")));
        setIfExists(afterNode, "x", x -> restaurantDto.setX(x.asDouble()));
        setIfExists(afterNode, "y", y -> restaurantDto.setY(y.asDouble()));
        setIfExists(afterNode, "city_id", cityId -> restaurantDto.setCityId(cityId.asInt()));
        setIfExists(afterNode, "food_category_id", foodCategoryId -> restaurantDto.setFoodCategoryId(foodCategoryId.asInt()));
        setIfExists(afterNode, "kakao_place_id", kakaoPlaceId -> restaurantDto.setKakaoPlaceId(kakaoPlaceId.asText("")));

        return restaurantDto;
    }

    // 안전한 필드 설정을 위한 제네릭 유틸리티 메서드
    private void setIfExists(JsonNode node, String fieldName, java.util.function.Consumer<JsonNode> setter) {
        JsonNode field = node.path(fieldName);
        if (!field.isMissingNode() && !field.isNull()) {
            setter.accept(field);
        }
    }
}