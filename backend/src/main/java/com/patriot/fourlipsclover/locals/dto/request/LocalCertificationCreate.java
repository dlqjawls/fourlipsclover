package com.patriot.fourlipsclover.locals.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class LocalCertificationCreate {

	// 위도 -> -90(남극) ~ +90 (북극) -> 광주의 위도는 북위 35.16
	private Double latitude;
	// 경도 -> -180(서경) ~ +180(동경) -> 광주의 경도는 동경 126.91
	private Double longitude;
}
