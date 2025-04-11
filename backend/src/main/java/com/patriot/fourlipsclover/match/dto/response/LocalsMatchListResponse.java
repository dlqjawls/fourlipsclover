package com.patriot.fourlipsclover.match.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class LocalsMatchListResponse {

    private Integer matchId;       // 매칭 ID
    private GuideRequestForm guideRequestForm;
    private Long applicantId;      // 신청자(매칭 요청자)의 회원 ID
    private String regionName;     // 지역 이름
    private LocalDateTime createdAt;  // 매칭 생성 일시
    private String matchingStatus;         // 매칭 상태 (PENDING, CONFIRMED, REJECTED, CANCELED)
    private Integer price;         // 팁 금액(결제 성공 후 데이터에서 가져올 예정)

}
