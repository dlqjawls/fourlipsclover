package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.ReviewImage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewImageRepository extends JpaRepository<ReviewImage, Integer> {

	List<ReviewImage> findByReviewReviewId(Integer reviewId);

	void deleteByImageUrl(String imageUrl);
}
