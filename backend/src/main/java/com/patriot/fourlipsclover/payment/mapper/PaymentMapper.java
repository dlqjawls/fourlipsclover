package com.patriot.fourlipsclover.payment.mapper;

import com.patriot.fourlipsclover.payment.dto.response.Amount;
import com.patriot.fourlipsclover.payment.dto.response.CardInfo;
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

	public PaymentApproveResponse toDto(PaymentApproval entity) {
		PaymentApproveResponse response = new PaymentApproveResponse();
		response.setAid(entity.getAid());
		response.setTid(entity.getTid());
		response.setCid(entity.getCid());
		response.setSid(entity.getSid());
		response.setPartnerOrderId(entity.getPartnerOrderId());
		response.setPartnerUserId(entity.getPartnerUserId());
		response.setPaymentMethodType(entity.getPaymentMethodType());

		if (entity.getAmount() != null) {
			Amount amount = new Amount();
			amount.setTotal(entity.getAmount().getTotal());
			amount.setTaxFree(entity.getAmount().getTaxFree());
			amount.setVat(entity.getAmount().getVat());
			amount.setPoint(entity.getAmount().getPoint());
			amount.setDiscount(entity.getAmount().getDiscount());
			amount.setGreenDeposit(entity.getAmount().getGreenDeposit());
			response.setAmount(amount);
		}

		if (entity.getCardInfo() != null) {
			CardInfo cardInfo = new CardInfo();
			cardInfo.setKakaopayPurchaseCorp(entity.getCardInfo().getPurchaseCorp());
			cardInfo.setKakaopayIssuerCorp(entity.getCardInfo().getIssuerCorp());
			cardInfo.setBin(entity.getCardInfo().getBin());
			cardInfo.setCardType(entity.getCardInfo().getCardType());
			cardInfo.setInstallMonth(entity.getCardInfo().getInstallMonth());
			cardInfo.setApprovedId(entity.getCardInfo().getApprovedId());
			response.setCardInfo(cardInfo);
		}

		response.setItemName(entity.getItemName());
		response.setItemCode(entity.getItemCode());
		response.setQuantity(entity.getQuantity());
		response.setCreatedAt(entity.getCreatedAt());
		response.setApprovedAt(entity.getApprovedAt());
		response.setPayload(entity.getPayload());
		response.setStatus(entity.getStatus().name());
		return response;
	}
}
