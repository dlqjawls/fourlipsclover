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
public class MatchDetailResponse {

    private Integer matchId;
    private String regionName;
    private String guideNickname;
    private String status;  // 상태 (PENDING, CONFIRMED, REJECTED)

    private String foodPreference;
    private String requirements;
    private String tastePreference;
    private String transportation;
    private LocalDate startDate;
    private LocalDate endDate;

    private LocalDateTime createdAt;  // guideRequestForm 생성시일

}
