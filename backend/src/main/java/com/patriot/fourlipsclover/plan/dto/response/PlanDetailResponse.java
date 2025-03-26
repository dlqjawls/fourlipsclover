package com.patriot.fourlipsclover.plan.dto.response;

import com.patriot.fourlipsclover.member.entity.Member;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlanDetailResponse {

    private Integer planId;
    private Integer groupId;
    private Long treasurerId;
    private String title;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime createdAt;
    private List<Member> members;

}
