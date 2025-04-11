package com.patriot.fourlipsclover.match.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LocalsProposalRequest {

    private Integer matchId;
    private List<Integer> restaurantIds;
    private String recommendMenu;
    private String description;

}
