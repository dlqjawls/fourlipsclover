package com.patriot.fourlipsclover.locals.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "local_certification")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LocalCertification {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int localCertificationId;
	@ManyToOne
	@JoinColumn(name = "member_id")
	private Member member;

	@ManyToOne
	@JoinColumn(name = "local_region_id")
	private LocalRegion localRegion;

	@Column
	private boolean certificated;
	@Column
	private LocalDateTime certificatedAt;
	@Column
	private LocalDateTime expiryAt;
	
	@Enumerated(value = EnumType.STRING)
	@Column(nullable = false)
	private LocalGrade localGrade;
}
