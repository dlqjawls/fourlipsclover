package com.patriot.fourlipsclover.plan.dto.request;

import com.patriot.fourlipsclover.plan.entity.PlanNoticeColor;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlanNoticeRequest {

    private boolean isImportant;
    private PlanNoticeColor color;
    private String content;

}
