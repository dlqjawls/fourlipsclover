package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RestaurantJpaRepository extends JpaRepository<Restaurant, Long> {

    Optional<Restaurant> findByKakaoPlaceId(String kakaoPlaceId);

    @Query(value = "SELECT * FROM restaurant " +
            "WHERE (6371 * acos(cos(radians(:latitude)) * cos(radians(x)) * " +
            "cos(radians(y) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(x)))) <= :radius/1000",
            nativeQuery = true)
    List<Restaurant> findNearbyRestaurants(
            @Param("latitude") Double latitude,
            @Param("longitude") Double longitude,
            @Param("radius") Integer radius);

    Restaurant findByRestaurantId(Integer restaurantId);
    
    boolean existsByRestaurantId(Integer restaurantId);
}
