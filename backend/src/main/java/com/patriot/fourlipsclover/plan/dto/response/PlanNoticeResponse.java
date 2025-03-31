package com.patriot.fourlipsclover.plan.dto.response;

import com.patriot.fourlipsclover.plan.entity.PlanNoticeColor;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class PlanNoticeResponse {

    private Integer planNoticeId;
    private Integer planId;
    private Long creatorId;
    private boolean isImportant;
    private PlanNoticeColor color;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

}
