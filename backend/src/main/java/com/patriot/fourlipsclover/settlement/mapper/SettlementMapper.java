package com.patriot.fourlipsclover.settlement.mapper;

import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementPaymentResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementResponse;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface SettlementMapper {

	@Mapping(source = "settlement.plan.title", target = "planName")
	@Mapping(source = "settlement.plan.planId", target = "planId")
	@Mapping(source = "settlement.treasurer.nickname", target = "treasurerName")
	@Mapping(source = "settlement.treasurer.memberId", target = "treasurerId")
	@Mapping(source = "paymentApprovals", target = "payments")
	SettlementResponse toDto(Settlement settlement, List<PaymentApproval> paymentApprovals);

	SettlementPaymentResponse toPaymentResponse(PaymentApproval paymentApproval);
}