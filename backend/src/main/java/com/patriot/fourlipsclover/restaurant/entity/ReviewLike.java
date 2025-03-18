package com.patriot.fourlipsclover.restaurant.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate.LikeStatus;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "review_like")
@Builder
@AllArgsConstructor
public class ReviewLike {

	@EmbeddedId
	private ReviewLikePK id;

	@ManyToOne
	@MapsId("reviewId")
	@JoinColumn(name = "review_id")
	private Review review;

	@ManyToOne
	@MapsId("memberId")
	@JoinColumn(name = "member_id")
	private Member member;

	@Enumerated(EnumType.STRING)
	private LikeStatus likeStatus;
}
