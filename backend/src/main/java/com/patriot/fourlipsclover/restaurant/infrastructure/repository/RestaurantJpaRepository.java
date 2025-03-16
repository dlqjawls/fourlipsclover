package com.patriot.fourlipsclover.restaurant.infrastructure.repository;

import com.patriot.fourlipsclover.restaurant.domain.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RestaurantJpaRepository extends JpaRepository<Restaurant, Long> {

}
