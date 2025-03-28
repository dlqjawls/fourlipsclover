package com.patriot.fourlipsclover.mypage.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MypageResponse {

	private Long memberId;

	private String email;

	private String nickname;

	private String profileUrl;

	private LocalDateTime createdAt;

	private float trustScore;
}
