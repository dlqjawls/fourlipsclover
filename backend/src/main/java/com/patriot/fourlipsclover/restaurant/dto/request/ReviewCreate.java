package com.patriot.fourlipsclover.restaurant.dto.request;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// 이미지 저장 추가하기.
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewCreate {

    private Long memberId;
    private String kakaoPlaceId;
    private String content;
    private LocalDateTime visitedAt;
}
