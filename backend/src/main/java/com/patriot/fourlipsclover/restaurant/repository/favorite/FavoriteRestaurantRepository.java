package com.patriot.fourlipsclover.restaurant.repository.favorite;

import com.patriot.fourlipsclover.restaurant.entity.favorite.FavoriteRestaurant;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteRestaurantRepository extends JpaRepository<FavoriteRestaurant, Integer> {

}
