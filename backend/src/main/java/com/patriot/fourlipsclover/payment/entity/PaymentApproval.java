package com.patriot.fourlipsclover.payment.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "payment_approvals")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentApproval {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String aid;
	private String tid;
	private String cid;
	private String sid;
	private String partnerOrderId;
	private String partnerUserId;
	private String paymentMethodType;

	@Embedded
	private PaymentAmount amount;

	@Embedded
	private PaymentCardInfo cardInfo;

	private String itemName;
	private String itemCode;
	private Integer quantity;

	@Column(name = "created_at")
	private LocalDateTime createdAt;

	@Column(name = "approved_at")
	private LocalDateTime approvedAt;

	private String payload;
}
