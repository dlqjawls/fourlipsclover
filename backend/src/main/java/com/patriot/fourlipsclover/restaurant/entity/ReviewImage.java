package com.patriot.fourlipsclover.restaurant.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "review_image")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewImage {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "review_image_id")
	private Integer reviewImageId;

	@ManyToOne
	@JoinColumn(name = "review_id", nullable = false)
	private Review review;

	@Column
	private String imageUrl;
	@Column
	private LocalDateTime createdAt;
}
