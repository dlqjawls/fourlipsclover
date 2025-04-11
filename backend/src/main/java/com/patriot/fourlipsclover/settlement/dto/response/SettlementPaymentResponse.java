package com.patriot.fourlipsclover.settlement.dto.response;

import com.patriot.fourlipsclover.payment.dto.response.Amount;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class SettlementPaymentResponse {

	private String aid;

	private String tid;

	private String cid;

	private String sid;

	private String partnerOrderId;

	private String partnerUserId;

	private String paymentMethodType;

	private Amount amount;

	private String itemName;

	private Integer quantity;

	private LocalDateTime createdAt;

	private LocalDateTime approvedAt;
}
