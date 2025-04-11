package com.patriot.fourlipsclover.payment.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {

	private String tid;
	private String nextDirectMobileUrl;
	private String androidAppScheme;
	private LocalDateTime createdAt;
}
