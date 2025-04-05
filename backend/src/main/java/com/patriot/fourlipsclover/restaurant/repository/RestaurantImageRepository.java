package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.RestaurantImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantImageRepository extends JpaRepository<RestaurantImage, Integer> {
    List<RestaurantImage> findByRestaurant(Restaurant restaurant);
    List<RestaurantImage> findByRestaurantRestaurantId(Integer restaurantId);
}
