package com.patriot.fourlipsclover.member.entity;

import com.patriot.fourlipsclover.tag.entity.Tag;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "member_review_tag")
@NoArgsConstructor
@AllArgsConstructor
@Data
public class MemberReviewTag {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "member_review_tag_id")
	private Long memberReviewTagId;

	@ManyToOne
	@JoinColumn(name = "member_id")
	private Member member;

	@ManyToOne
	@JoinColumn(name = "tag_id")
	private Tag tag;

	@Column(name = "frequency")
	private int frequency;

	@Column(name = "avg_confidence")
	private float avgConfidence;
}
