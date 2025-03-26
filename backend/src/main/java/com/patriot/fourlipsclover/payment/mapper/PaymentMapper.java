package com.patriot.fourlipsclover.payment.mapper;

import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.entity.PaymentAmount;
import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import com.patriot.fourlipsclover.payment.entity.PaymentCardInfo;
import org.springframework.stereotype.Component;

@Component
public class PaymentMapper {

	public PaymentApproval toEntity(PaymentApproveResponse response) {
		return PaymentApproval.builder()
				.aid(response.getAid())
				.tid(response.getTid())
				.cid(response.getCid())
				.sid(response.getSid())
				.partnerOrderId(response.getPartnerOrderId())
				.partnerUserId(response.getPartnerUserId())
				.paymentMethodType(response.getPaymentMethodType())
				.amount(new PaymentAmount(
						response.getAmount().getTotal(),
						response.getAmount().getTaxFree(),
						response.getAmount().getVat(),
						response.getAmount().getPoint(),
						response.getAmount().getDiscount(),
						response.getAmount().getGreenDeposit()))
				.cardInfo(response.getCardInfo() != null ? new PaymentCardInfo(
						response.getCardInfo().getKakaopayPurchaseCorp(),
						response.getCardInfo().getKakaopayIssuerCorp(),
						response.getCardInfo().getBin(),
						response.getCardInfo().getCardType(),
						response.getCardInfo().getInstallMonth(),
						response.getCardInfo().getApprovedId()) : null)
				.itemName(response.getItemName())
				.itemCode(response.getItemCode())
				.quantity(response.getQuantity())
				.createdAt(response.getCreatedAt())
				.approvedAt(response.getApprovedAt())
				.payload(response.getPayload())
				.build();
	}
}
