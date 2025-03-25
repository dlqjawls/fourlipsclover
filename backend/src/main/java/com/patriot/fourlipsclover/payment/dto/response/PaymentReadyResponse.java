package com.patriot.fourlipsclover.payment.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data
public class PaymentReadyResponse {

	private String tid;
	private String orderId;
	private String nextRedirect;
	private String nextRedirectMobileUrl;
	private String androidAppScheme;
	private LocalDateTime createdAt;
}
