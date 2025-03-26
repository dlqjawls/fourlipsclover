package com.patriot.fourlipsclover.payment.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Amount {

	@JsonProperty("total")
	private Integer total;

	@JsonProperty("tax_free")
	private Integer taxFree;

	@JsonProperty("vat")
	private Integer vat;

	@JsonProperty("point")
	private Integer point;

	@JsonProperty("discount")
	private Integer discount;

	@JsonProperty("green_deposit")
	private Integer greenDeposit;
}
