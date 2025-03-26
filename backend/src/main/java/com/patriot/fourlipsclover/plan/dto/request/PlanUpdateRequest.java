package com.patriot.fourlipsclover.plan.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanUpdateRequest {

    private String title;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;

}
