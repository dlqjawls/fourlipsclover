package com.patriot.fourlipsclover.locals.dto.response;

import com.patriot.fourlipsclover.locals.entity.LocalGrade;
import com.patriot.fourlipsclover.locals.entity.LocalRegion;
import com.patriot.fourlipsclover.member.entity.Member;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LocalCertificationResponse {

	private int localCertificationId;
	private Member member;

	private LocalRegion localRegion;

	private boolean certificated;
	private LocalDateTime certificatedAt;
	private LocalDateTime expiryAt;

	private LocalGrade localGrade;
}
