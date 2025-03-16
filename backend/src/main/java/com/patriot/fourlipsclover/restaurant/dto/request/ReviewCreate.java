package com.patriot.fourlipsclover.restaurant.dto.request;


import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// 이미지 저장 추가하기.
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewCreate {

	private int memberId;
	private String kakaoPlaceId;
	private String content;
	private LocalDateTime visitedAt;
}
