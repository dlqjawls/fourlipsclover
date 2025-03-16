package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewJpaRepository extends JpaRepository<Review, Integer> {

}
