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
public class LocalsConfirmResponse {

    private String regionName;
    private String status;  // 상태 (PENDING, CONFIRMED, REJECTED)
    private Long matchCreatorId;
    private Integer matchId;

    private String foodPreference;
    private String requirements;
    private String tastePreference;
    private String transportation;
    private LocalDate startDate;
    private LocalDate endDate;

    private LocalDateTime createdAt;  // confirmed 된 시일

}
