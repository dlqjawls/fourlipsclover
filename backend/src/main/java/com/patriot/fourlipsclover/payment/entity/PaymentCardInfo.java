package com.patriot.fourlipsclover.payment.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCardInfo {

	private String purchaseCorp;
	private String issuerCorp;
	private String bin;
	private String cardType;
	private String installMonth;
	private String approvedId;
}