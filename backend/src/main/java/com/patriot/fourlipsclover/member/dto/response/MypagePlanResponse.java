package com.patriot.fourlipsclover.member.dto.response;

import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class MypagePlanResponse {
	private Integer planId;
	private String title;
	private String description;
	private LocalDate startDate;
	private LocalDate endDate;
}
