package com.patriot.fourlipsclover.locals.mapper;

import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import org.springframework.stereotype.Component;

@Component
public class LocalCertificationMapper {

	public LocalCertificationResponse toDto(LocalCertification localCertification) {
		return LocalCertificationResponse.builder()
				.localCertificationId(localCertification.getLocalCertificationId())
				.member(localCertification.getMember())
				.localRegion(localCertification.getLocalRegion())
				.certificated(localCertification.isCertificated())
				.certificatedAt(localCertification.getCertificatedAt())
				.expiryAt(localCertification.getExpiryAt())
				.localGrade(localCertification.getLocalGrade())
				.build();
	}
}
