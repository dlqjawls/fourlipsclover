package com.patriot.fourlipsclover.restaurant.dto.response;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteRestaurantResponse {

	private Integer favoriteRestaurantId;
	private Long memberId;
	private String nickname;
	private String profileUrl;

	private Restaurant restaurant;
	private LocalDateTime createdAt;
}
