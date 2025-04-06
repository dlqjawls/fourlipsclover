package com.patriot.fourlipsclover.plan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EditTreasurerResponse {

    private int planId;

    private Long oldTreasurerId;
    private String oldTreasurerNickname;

    private Long newTreasurerId;
    private String newTreasurerNickname;

}
