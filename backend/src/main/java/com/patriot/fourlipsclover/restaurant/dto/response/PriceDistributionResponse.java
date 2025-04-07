package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class PriceDistributionResponse {
    private Integer totalPersonnel;
    private Map<String, Integer> priceRangeDistribution;
}
