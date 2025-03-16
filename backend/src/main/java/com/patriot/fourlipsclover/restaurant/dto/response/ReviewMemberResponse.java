package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewMemberResponse {
	private int memberId;
	private String name;
	private String nickname;
	private String email;
}
