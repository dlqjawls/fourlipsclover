package com.patriot.fourlipsclover.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

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

    @JsonProperty("item_name")
    private String itemName;
    @JsonProperty("quantity")
    private String quantity;
    @JsonProperty("total_amount")
    private String totalAmount;

}
