package com.patriot.fourlipsclover.restaurant.dto.kafka;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantKafkaDto {
    // 메인 데이터
    private Integer restaurantId;
    private String placeName;
    private String addressName;
    private String roadAddressName;
    private String categoryName;
    private String phone;
    private String placeUrl;
    private Double x;
    private Double y;
    private Integer cityId;
    private Integer foodCategoryId;
    private String kakaoPlaceId; // Added Kakao Place ID field

    // CDC 메타데이터
    private String op;  // 작업 유형: c=create, u=update, d=delete
    private LocalDateTime eventTimestamp;  // 이벤트 발생 시간

    // Debezium 형식에서 데이터 추출을 위한 중첩 클래스들
    @Data
    public static class Payload {
        private Source source;
        private Before before;
        private After after;
        private String op;
        private Integer ts_ms;
    }

    @Data
    public static class Source {
        private String version;
        private String connector;
        private String name;
        private Integer ts_ms;
        private String db;
        private String schema;
        private String table;
    }

    @Data
    public static class Before {
        private Integer restaurantId;
        private String placeName;
        private String addressName;
        private String roadAddressName;
        private String categoryName;
        private String phone;
        private String placeUrl;
        private Double x;
        private Double y;
        private Integer cityId;
        private Integer foodCategoryId;
        private String kakaoPlaceId; // Added Kakao Place ID field
    }

    @Data
    public static class After {
        private Integer restaurantId;
        private String placeName;
        private String addressName;
        private String roadAddressName;
        private String categoryName;
        private String phone;
        private String placeUrl;
        private Double x;
        private Double y;
        private Integer cityId;
        private Integer foodCategoryId;
        private String kakaoPlaceId; // Added Kakao Place ID field
    }

    /**
     * Debezium 형식의 JSON에서 주요 데이터를 추출하여 DTO에 설정
     */
    public static RestaurantKafkaDto fromDebeziumPayload(Payload payload) {
        RestaurantKafkaDto dto = new RestaurantKafkaDto();

        // 작업 유형 설정
        dto.setOp(payload.getOp());

        // 타임스탬프 설정
        if (payload.getTs_ms() != null) {
            dto.setEventTimestamp(LocalDateTime.ofEpochSecond(
                    payload.getTs_ms() / 1000,
                    (int)((payload.getTs_ms() % 1000) * 1000000),
                    java.time.ZoneOffset.UTC
            ));
        }

        // 작업 유형에 따라 적절한 데이터 설정
        if ("d".equals(payload.getOp())) {
            // 삭제의 경우, before 데이터 사용
            if (payload.getBefore() != null) {
                dto.setRestaurantId(payload.getBefore().getRestaurantId());
                // 삭제의 경우 ID만 필요할 수 있음
            }
        } else {
            // 삽입/수정의 경우, after 데이터 사용
            if (payload.getAfter() != null) {
                dto.setRestaurantId(payload.getAfter().getRestaurantId());
                dto.setPlaceName(payload.getAfter().getPlaceName());
                dto.setAddressName(payload.getAfter().getAddressName());
                dto.setRoadAddressName(payload.getAfter().getRoadAddressName());
                dto.setCategoryName(payload.getAfter().getCategoryName());
                dto.setPhone(payload.getAfter().getPhone());
                dto.setPlaceUrl(payload.getAfter().getPlaceUrl());
                dto.setX(payload.getAfter().getX());
                dto.setY(payload.getAfter().getY());
                dto.setCityId(payload.getAfter().getCityId());
                dto.setFoodCategoryId(payload.getAfter().getFoodCategoryId());
                dto.setKakaoPlaceId(payload.getAfter().getKakaoPlaceId()); // Added Kakao Place ID
            }
        }

        return dto;
    }
}