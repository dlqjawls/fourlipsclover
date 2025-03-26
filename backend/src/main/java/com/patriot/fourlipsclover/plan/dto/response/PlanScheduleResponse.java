package com.patriot.fourlipsclover.plan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanScheduleResponse {

    private Integer planScheduleId;
    private String placeName;  // 방문 장소
    private String notes;      // 추가 메모
    private LocalDateTime visitAt;  // 방문 예정 일시

}
