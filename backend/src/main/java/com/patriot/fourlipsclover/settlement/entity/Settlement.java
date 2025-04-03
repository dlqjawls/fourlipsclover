package com.patriot.fourlipsclover.settlement.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.plan.entity.Plan;
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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "settlement")
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Getter
@ToString
public class Settlement {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer settlementId;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "plan_id", unique = true)
	private Plan plan;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "member_id")
	private Member treasurer;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private SettlementStatus settlementStatus;

	@Column(nullable = false)
	private LocalDateTime startDate;

	@Column(nullable = false)
	private LocalDateTime endDate;

	@CreationTimestamp
	private LocalDateTime createdAt;

	@UpdateTimestamp
	private LocalDateTime updatedAt;

	public enum SettlementStatus {
		PENDING,
		IN_PROGRESS,
		COMPLETED,
		CANCELED
	}
}