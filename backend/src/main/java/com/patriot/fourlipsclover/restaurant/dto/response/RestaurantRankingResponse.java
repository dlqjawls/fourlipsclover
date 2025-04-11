package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantRankingResponse {
    private Integer restaurantId;
    private String placeName;
    private Integer visitCount;
    private Double weightedPositive;
    private Double weightedNegative;
    private Double avgUserTrustScore;  // 테이블에는 trust_score 필드가 있음
    private Integer reviewCount;
    private Double avgPerPersonAmount;
    private Double score;
    private Integer rank;
    private String categoryName;       // 카테고리 정보 추가
    private String mainCategoryName;
}
