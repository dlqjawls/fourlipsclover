package com.patriot.fourlipsclover.plan.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanScheduleCreateRequest {

    private Integer restaurantId;  // 방문 장소
    private String notes;      // 추가 메모
    private LocalDateTime visitAt;  // 방문 예정 일시

}