package com.patriot.fourlipsclover.plan.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlanScheduleDetailResponse {

    private Integer planId;
    private Integer planScheduleId;
    private String notes;
    private LocalDateTime visitAt;
    private LocalDateTime updatedAt;

    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Restaurant restaurant;

}
