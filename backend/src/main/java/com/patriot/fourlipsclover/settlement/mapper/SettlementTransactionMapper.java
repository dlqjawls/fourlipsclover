package com.patriot.fourlipsclover.settlement.mapper;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementMemberResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementSituationResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementTransactionResponse;
import com.patriot.fourlipsclover.settlement.dto.response.TreasurerResponse;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface SettlementTransactionMapper {


	SettlementTransactionResponse toDto(SettlementTransaction settlementTransaction);


	SettlementMemberResponse toMemberResponse(Member member);


	TreasurerResponse toTreasureResponse(Member member);


	@Mapping(source = "settlement.settlementId", target = "settlementId")
	@Mapping(source = "settlement.plan.title", target = "planName")
	@Mapping(source = "settlement.plan.planId", target = "planId")
	@Mapping(source = "settlement.treasurer.nickname", target = "treasurerName")
	@Mapping(source = "settlement.treasurer.memberId", target = "treasurerId")
	@Mapping(source = "settlement.settlementStatus", target = "settlementStatus")
	@Mapping(source = "settlement.startDate", target = "startDate")
	@Mapping(source = "settlement.endDate", target = "endDate")
	@Mapping(source = "settlementTransaction", target = "settlementTransactionResponses")
	SettlementSituationResponse toSettlementResponse(Settlement settlement,
			List<SettlementTransaction> settlementTransaction);

	List<SettlementSituationResponse> toSettlementResponses(
			List<SettlementTransaction> settlementTransactions);
}
