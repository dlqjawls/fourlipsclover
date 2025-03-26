package com.patriot.fourlipsclover.plan.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class PlanMemberId implements Serializable {

    private Integer planId;
    private Long memberId;

}
