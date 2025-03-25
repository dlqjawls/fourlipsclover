package com.patriot.fourlipsclover.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
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

	@JsonProperty("tid")
	private String tid;

	private String orderId;
	@JsonProperty("next_redirect_app_url")
	private String nextRedirectAppUrl;
	@JsonProperty("next_redirect_mobile_url")
	private String nextRedirectMobileUrl;
	@JsonProperty("next_redirect_pc_url")
	private String nextRedirectPcUrl;
	@JsonProperty("android_app_scheme")
	private String androidAppScheme;
	@JsonProperty("created_at")
	private LocalDateTime createdAt;
}
