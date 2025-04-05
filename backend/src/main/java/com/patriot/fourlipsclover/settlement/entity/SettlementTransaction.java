package com.patriot.fourlipsclover.settlement.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "settlement_transaction")
@NoArgsConstructor
@AllArgsConstructor
@Data
public class SettlementTransaction {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long settlementTransactionId;

	@Column
	private Integer cost;
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "payee_id")
	private Member payee;                    // 수취인

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "payer_id")
	private Member payer;                    // 송금자

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "settlement_id")
	private Settlement settlement;           // 연관 정산 기록

	@Enumerated(EnumType.STRING)
	@Column(name = "transaction_status")
	private TransactionStatus transactionStatus; // ENUM 혹은 상태 코드

	@CreationTimestamp
	private LocalDateTime createdAt;

	@Column(name = "sent_at")
	private LocalDateTime sentAt;

	public enum TransactionStatus {
		PENDING, // 대기 중
		COMPLETED, // 완료됨
		FAILED, // 실패함
		CANCELED // 취소됨
	}
}