package com.patriot.fourlipsclover.restaurant.dto.kafka;

import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("restaurant_id")
    private Integer restaurantId;

    @JsonProperty("place_name")
    private String placeName;

    @JsonProperty("address_name")
    private String addressName;

    @JsonProperty("road_address_name")
    private String roadAddressName;

    @JsonProperty("category_name")
    private String categoryName;

    private String phone;

    @JsonProperty("place_url")
    private String placeUrl;

    private Double x;
    private Double y;

    @JsonProperty("city_id")
    private Integer cityId;

    @JsonProperty("food_category_id")
    private Integer foodCategoryId;

    @JsonProperty("kakao_place_id")
    private String kakaoPlaceId;

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
        @JsonProperty("restaurant_id")
        private Integer restaurantId;

        @JsonProperty("place_name")
        private String placeName;

        @JsonProperty("address_name")
        private String addressName;

        @JsonProperty("road_address_name")
        private String roadAddressName;

        @JsonProperty("category_name")
        private String categoryName;

        private String phone;

        @JsonProperty("place_url")
        private String placeUrl;

        private Double x;
        private Double y;

        @JsonProperty("city_id")
        private Integer cityId;

        @JsonProperty("food_category_id")
        private Integer foodCategoryId;

        @JsonProperty("kakao_place_id")
        private String kakaoPlaceId;
    }

    @Data
    public static class After {
        @JsonProperty("restaurant_id")
        private Integer restaurantId;

        @JsonProperty("place_name")
        private String placeName;

        @JsonProperty("address_name")
        private String addressName;

        @JsonProperty("road_address_name")
        private String roadAddressName;

        @JsonProperty("category_name")
        private String categoryName;

        private String phone;

        @JsonProperty("place_url")
        private String placeUrl;

        private Double x;
        private Double y;

        @JsonProperty("city_id")
        private Integer cityId;

        @JsonProperty("food_category_id")
        private Integer foodCategoryId;

        @JsonProperty("kakao_place_id")
        private String kakaoPlaceId;
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
                mapAfterToDto(payload.getAfter(), dto);
            }
        }

        return dto;
    }

    // 별도의 메서드로 매핑 로직 분리
    private static void mapAfterToDto(After after, RestaurantKafkaDto dto) {
        dto.setRestaurantId(after.getRestaurantId());
        dto.setPlaceName(after.getPlaceName());
        dto.setAddressName(after.getAddressName());
        dto.setRoadAddressName(after.getRoadAddressName());
        dto.setCategoryName(after.getCategoryName());
        dto.setPhone(after.getPhone());
        dto.setPlaceUrl(after.getPlaceUrl());
        dto.setX(after.getX());
        dto.setY(after.getY());
        dto.setCityId(after.getCityId());
        dto.setFoodCategoryId(after.getFoodCategoryId());
        dto.setKakaoPlaceId(after.getKakaoPlaceId());
    }
}