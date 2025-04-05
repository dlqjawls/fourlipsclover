package com.patriot.fourlipsclover.match.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GuideRequestFormRequest {
    private Integer groupId;
    private String transportation;  // 교통수단
    private String foodPreference;  // 음식 취향
    private String tastePreference; // 맛 취향
    private String requirements;    // 요청 사항
    private LocalDate startDate;    // 여행 시작일
    private LocalDate endDate;      // 여행 종료일
}
