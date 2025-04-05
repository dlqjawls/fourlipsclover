package com.patriot.fourlipsclover.settlement.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SettlementMemberResponse {

	private Long memberId;

	private String email;

	private String nickname;

	private String profileUrl;

}
