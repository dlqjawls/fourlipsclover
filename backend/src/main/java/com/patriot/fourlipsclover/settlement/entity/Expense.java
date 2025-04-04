package com.patriot.fourlipsclover.settlement.entity;

import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "expense")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class Expense {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long expenseId;
	@ManyToOne
	@JoinColumn(name = "settlement_id")
	private Settlement settlement;

	@ManyToOne
	@JoinColumn(name = "payment_approval_id")
	private PaymentApproval paymentApproval;

	@CreationTimestamp
	private LocalDateTime createdAt;
}
