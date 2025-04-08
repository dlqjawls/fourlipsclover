package com.patriot.fourlipsclover.settlement.mapper;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementMemberResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementSituationResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementTransactionResponse;
import com.patriot.fourlipsclover.settlement.dto.response.TreasurerResponse;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import java.util.List;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface SettlementTransactionMapper {


	SettlementTransactionResponse toDto(SettlementTransaction settlementTransaction);


	SettlementMemberResponse toMemberResponse(Member member);


	TreasurerResponse toTreasureResponse(Member member);

	SettlementTransactionResponse toSettlementTransactionResponse(Member member);

	SettlementSituationResponse toSettlementResponse(SettlementTransaction settlementTransaction);

	List<SettlementSituationResponse> toSettlementResponses(
			List<SettlementTransaction> settlementTransactions);
}
