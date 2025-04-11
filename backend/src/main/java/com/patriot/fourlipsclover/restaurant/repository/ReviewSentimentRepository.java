package com.patriot.fourlipsclover.restaurant.repository;


import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.ReviewSentiment;
import com.patriot.fourlipsclover.restaurant.entity.SentimentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewSentimentRepository extends JpaRepository<ReviewSentiment, Long> {


	int countByReview_RestaurantAndSentimentStatus(Restaurant restaurant, SentimentStatus sentimentStatus);
}
