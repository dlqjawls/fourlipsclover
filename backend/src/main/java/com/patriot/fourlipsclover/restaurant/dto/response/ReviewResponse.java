package com.patriot.fourlipsclover.restaurant.dto.response;

import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.cglib.core.Local;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class ReviewResponse {

	private Integer reviewId;

	private ReviewMemberResponse reviewer;

	private ReviewRestaurantResponse restaurant;

	private String content;

	private LocalDateTime visitedAt;

	private LocalDateTime createdAt;

	private LocalDateTime updatedAt;

	private List<String> reviewImageUrls;

	private Integer likedCount;

	private Integer dislikedCount;

	private boolean userLiked;

	private boolean userDisliked;

	private LocalCertificationResponse localCertificationResponse;
}
