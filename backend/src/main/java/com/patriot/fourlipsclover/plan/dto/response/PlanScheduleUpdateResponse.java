package com.patriot.fourlipsclover.plan.dto.response;

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
public class PlanScheduleUpdateResponse {

    private Restaurant restaurant;
    private String placeName;  // 방문 장소
    private String notes;      // 추가 메모
    private LocalDateTime visitAt;  // 방문 예정 일시

}
