package com.patriot.fourlipsclover.plan.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanScheduleUpdateRequest {

    private Integer restaurantId;
    private String notes;      // 추가 메모
    private LocalDateTime visitAt;  // 변경된 방문 예정 일시

}
