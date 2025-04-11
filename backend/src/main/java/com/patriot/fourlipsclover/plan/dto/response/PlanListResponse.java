package com.patriot.fourlipsclover.plan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanListResponse {

    // planId, startDate, endDate만 주면 될 것 같음, 조율 후 적용예정
    private Integer planId;
    private Integer groupId;
    private Long treasurerId;
    private String title;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime createdAt;

}
