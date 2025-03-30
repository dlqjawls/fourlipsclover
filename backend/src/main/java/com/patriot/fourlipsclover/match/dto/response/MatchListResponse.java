package com.patriot.fourlipsclover.match.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MatchListResponse {

    private String regionName;  // 지역 이름
    private String guideNickname;  // 가이드의 닉네임
    private LocalDateTime createdAt;  // 매칭 생성일
    private LocalDate startDate;  // 시작일
    private LocalDate endDate;  // 종료일
    private String status;  // 상태 (PENDING, CONFIRMED, REJECTED)

}
