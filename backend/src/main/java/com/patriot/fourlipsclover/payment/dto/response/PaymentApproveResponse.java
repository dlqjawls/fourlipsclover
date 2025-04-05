package com.patriot.fourlipsclover.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentApproveResponse {

	@JsonProperty("aid")
	private String aid;

	@JsonProperty("tid")
	private String tid;

	@JsonProperty("cid")
	private String cid;

	@JsonProperty("sid")
	private String sid;

	@JsonProperty("partner_order_id")
	private String partnerOrderId;

	@JsonProperty("partner_user_id")
	private String partnerUserId;

	@JsonProperty("payment_method_type")
	private String paymentMethodType;

	@JsonProperty("amount")
	private Amount amount;

	@JsonProperty("card_info")
	private CardInfo cardInfo;

	@JsonProperty("item_name")
	private String itemName;

	@JsonProperty("item_code")
	private String itemCode;

	@JsonProperty("quantity")
	private Integer quantity;

	@JsonProperty("created_at")
	private LocalDateTime createdAt;

	@JsonProperty("approved_at")
	private LocalDateTime approvedAt;

	@JsonProperty("payload")
	private String payload;
	@JsonProperty("status")
	private String status;
}
