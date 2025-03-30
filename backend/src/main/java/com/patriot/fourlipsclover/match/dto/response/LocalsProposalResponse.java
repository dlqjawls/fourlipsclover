package com.patriot.fourlipsclover.match.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LocalsProposalResponse {

    private Integer proposalId;       // 기획서 고유 ID
    private Integer matchId;          // 연결된 매칭의 ID
    private List<Long> restaurantIds; // 추천 식당들의 ID 목록 (필요시 이름이나 DTO로 확장 가능)
    private String recommendMenu;     // 추천 메뉴
    private String description;       // 기획서 상세 설명

}
