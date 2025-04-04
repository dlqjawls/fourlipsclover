package com.patriot.fourlipsclover.settlement.mapper;

import com.patriot.fourlipsclover.settlement.dto.response.SettlementTransactionResponse;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface SettlementTransactionMapper {
	
	SettlementTransactionResponse toDto(SettlementTransaction settlementTransaction);
}
