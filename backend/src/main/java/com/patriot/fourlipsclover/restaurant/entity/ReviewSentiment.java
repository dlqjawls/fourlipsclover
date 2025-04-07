package com.patriot.fourlipsclover.restaurant.entity;

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
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "review_sentiment")
@NoArgsConstructor
@AllArgsConstructor
@Data
public class ReviewSentiment {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "review_sentiment_id")
	private Long reviewSentimentId;

	@ManyToOne
	@JoinColumn(name = "review_id")
	private Review review;

	@Enumerated(EnumType.STRING)
	@Column(name = "sentiment_status")
	private SentimentStatus sentimentStatus;
}
