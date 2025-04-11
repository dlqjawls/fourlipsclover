package com.patriot.fourlipsclover.member.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "member")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Member {

	@Id
	private Long memberId;

	@Column(nullable = false)
	private String email;

	@Column(nullable = false)
	private String nickname;

	@Column(length = 1000, nullable = true)
	private String profileUrl;

	@Column(name = "created_at", insertable = false, updatable = false,
			columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
	private LocalDateTime createdAt;

	@Column(name = "updated_at", insertable = false,
			columnDefinition = "TIMESTAMP NULL DEFAULT NULL")
	private LocalDateTime updatedAt;

	@Column(name = "withdrawal_at", insertable = false,
			columnDefinition = "TIMESTAMP NULL DEFAULT NULL")
	private LocalDateTime withdrawalAt;

	@Column(name = "is_withdrawal", insertable = false,
			columnDefinition = "BOOLEAN DEFAULT FALSE")
	private Boolean isWithdrawal;

	@Column(name = "trust_score", insertable = false,
			columnDefinition = "FLOAT DEFAULT 0")
	private float trustScore;

	@Enumerated(EnumType.STRING)
	@Column(name = "gender")
	private Gender gender;

	@Column(name = "age")
	private Integer age;

}
