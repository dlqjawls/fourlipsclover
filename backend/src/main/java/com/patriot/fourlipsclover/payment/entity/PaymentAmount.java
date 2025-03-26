package com.patriot.fourlipsclover.payment.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentAmount {

	private Integer total;
	private Integer taxFree;
	private Integer vat;
	private Integer point;
	private Integer discount;
	private Integer greenDeposit;
}
