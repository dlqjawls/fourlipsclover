package com.patriot.fourlipsclover.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCancelResponse {

	@JsonProperty("tid")
	private String tid;
	@JsonProperty("cid")
	private String cid;
	@JsonProperty("status")
	private String status;
	@JsonProperty("partner_order_id")
	private String partner_order_id;
	@JsonProperty("partner_user_id")
	private String partner_user_id;
	@JsonProperty("payment_method_type")
	private String payment_method_type;
	@JsonProperty("item_name")
	private String item_name;
	@JsonProperty("quantity")
	private int quantity;
	@JsonProperty("amount")
	private Amount amount;
	@JsonProperty("approved_cancel_amount")
	private Amount approved_cancel_amount;
	@JsonProperty("canceled_amount")
	private Amount canceled_amount;
	@JsonProperty("cancel_available_amount")
	private Amount cancel_available_amount;
	@JsonProperty("created_at")
	private String created_at;
	@JsonProperty("approved_at")
	private String approved_at;
	@JsonProperty("canceled_at")
	private String canceled_at;

}
